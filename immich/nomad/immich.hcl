
// immich photo database
// Docker Image: ghcr.io/immich-app/immich-server:release

///////////////////////////////////////////////////////////////////////////////
// VARIABLES

variable "dc" {
  description = "data centers that the job is eligible to run in"
  type        = list(string)
}

variable "namespace" {
  description = "namespace that the job runs in"
  type        = string
  default     = "default"
}

variable "hosts" {
  description = "host constraint for the job"
  type        = list(string)
  default     = []
}

variable "memory" {
  description = "memory allocation (MB) for the server, redis and ml tasks"
  type        = object({ server = number, redis = number, ml = number })
}

variable "redis" {
  description = "external redis server, or empty host to run a redis task"
  type        = object({ host = string, port = number })
}

variable "ml" {
  description = "run the machine learning group"
  type        = bool
}

variable "mlhosts" {
  description = "machine learning host constraint for the job"
  type        = list(string)
  default     = []
}

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "docker_image" {
  description = "Docker image"
  type        = string
}

variable "docker_redis_image" {
  description = "Docker image for redis"
  type        = string
}

variable "docker_ml_image" {
  description = "Docker image for machine learning"
  type        = string
}

variable "docker_ml_runtime" {
  description = "Docker runtime for machine learning"
  type        = string
  default     = ""
}

variable "docker_always_pull" {
  description = "Pull docker image on every job restart"
  type        = bool
  default     = false
}

///////////////////////////////////////////////////////////////////////////////

variable "port" {
  description = "Port for app connections"
  type        = number
  default     = 2283
}

variable "mlport" {
  description = "Port for machine learning connections"
  type        = number
  default     = 3003
}

variable "data" {
  description = "Data persistence directory"
  type        = string
}

variable "media" {
  description = "media volumes for media files"
  type        = list(string)
  default     = []
}

variable "database" {
  description = "Database connection parameters"
  type        = object({ host = string, port = number, name = string, user = string, password = string, ssl_mode = string })
  default     = { host : "", port : 0, name : "", user : "", password : "", ssl_mode : "" }
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  upload_location = "/upload"
  media = [
    for i, media in var.media : format("%s:/media%s", media, i == 0 ? "" : (i + 1))
  ]
  volumes = compact(flatten([
    var.data == "" ? "" : format("%s:%s", var.data, local.upload_location),
    local.media,
    "/etc/localtime:/etc/localtime:ro",
  ]))
}


///////////////////////////////////////////////////////////////////////////////
// JOB

job "immich" {
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "app" {
    dynamic "constraint" {
      for_each = length(var.hosts) == 0 ? [] : [join(",", var.hosts)]
      content {
        attribute = node.unique.name
        operator  = "set_contains_any"
        value     = constraint.value
      }
    }

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    network {
      port "http" {
        static = var.port
        to     = 2283
      }

      dynamic "port" {
        for_each = var.redis.host == "" ? ["redis"] : []
        labels   = [port.value]
        content {
          static = 6379
        }
      }
    }

    service {
      tags     = ["immich", "http"]
      name     = "immich-http"
      port     = "http"
      provider = var.service_provider
    }

    task "server" {
      driver = "docker"

      // Reserve memory
      resources {
        memory = var.memory.server
      }

      // Environment variables
      env {
        IMMICH_MEDIA_LOCATION = local.upload_location
        DB_HOSTNAME           = var.database.host
        DB_PORT               = var.database.port
        DB_DATABASE_NAME      = var.database.name
        DB_USERNAME           = var.database.user
        DB_PASSWORD           = var.database.password
        DB_VECTOR_EXTENSION   = "pgvector"
        REDIS_HOSTNAME        = var.redis.host == "" ? "$${NOMAD_IP_redis}" : var.redis.host
        REDIS_PORT            = var.redis.host == "" ? "$${NOMAD_PORT_redis}" : var.redis.port
        REDIS_USERNAME        = ""
        REDIS_PASSWORD        = ""
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = ["http"]
        dns_servers = var.service_dns
        volumes     = local.volumes
      }

    } // task "server"

    dynamic "task" {
      for_each = var.redis.host == "" ? ["redis"] : []
      labels   = [task.value]
      content {
        driver = "docker"

        config {
          image       = var.docker_redis_image
          force_pull  = var.docker_always_pull
          ports       = ["redis"]
          dns_servers = var.service_dns
        }

        // Reserve memory
        resources {
          memory = var.memory.redis
        }
      }
    } // task "redis"
  } // group "app"

  /////////////////////////////////////////////////////////////////////////////////

  group "ml" {
    count = var.ml ? 1 : 0

    dynamic "constraint" {
      for_each = length(var.mlhosts) == 0 ? [] : [join(",", var.mlhosts)]
      content {
        attribute = node.unique.name
        operator  = "set_contains_any"
        value     = constraint.value
      }
    }

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    network {
      port "ml" {
        static = var.mlport
        to     = 3003
      }
    }

    service {
      tags     = ["immich", "ml"]
      name     = "immich-ml"
      port     = "ml"
      provider = var.service_provider
    }

    task "ml" {
      driver = "docker"

      // Reserve memory
      resources {
        memory = var.memory.ml
      }

      config {
        image       = var.docker_ml_image
        runtime     = var.docker_ml_runtime
        force_pull  = var.docker_always_pull
        ports       = ["ml"]
        dns_servers = var.service_dns
      }
    } // task "ml"
  } // group "mp"
}   // job "immich"
