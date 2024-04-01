
// mongodb document database
// Docker Image: https://hub.docker.com/_/mongo

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
  description = "host constraint for the job, defaults to one host"
  type        = list(string)
  default     = []
}

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "mongodb"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "service_type" {
  description = "Run as a service or system"
  type        = string
  default     = "service"
}

variable "dns_servers" {
  description = "Task DNS servers"
  type        = list(string)
  default     = []
}

variable "docker_image" {
  description = "Docker image"
  type        = string
}

variable "docker_always_pull" {
  description = "Pull docker image on every job restart"
  type        = bool
  default     = false
}

variable "port" {
  description = "Port for plaintext connections"
  type        = number
  default     = 27017
}

variable "data" {
  type        = string
  description = "Directory for data persistence"
  default     = ""
}

variable "admin_password" {
  description = "password for 'admin' user (required)"
  type        = string
  sensitive   = true
}

variable "replicaset_name" {
  description = "replica set name"
  type        = string
  default    = "rs0"
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "mongodb" {
  type        = var.service_type
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "mongodb" {
    count = (length(var.hosts) == 0 || var.service_type == "system") ? 1 : length(var.hosts)

    dynamic "constraint" {
      for_each = length(var.hosts) == 0 ? [] : [join(",", var.hosts)]
      content {
        attribute = node.unique.name
        operator  = "set_contains_any"
        value     = constraint.value
      }
    }

    network {
      port "mongodb" {
        static = var.port
        to     = 27017
      }
    }

    service {
      tags     = ["mongodb"]
      name     = var.service_name
      port     = "mongodb"
      provider = var.service_provider
    }

    ephemeral_disk {
      migrate = true
    }

    task "server" {
      driver = "docker"

      env {
        MONGO_INITDB_ROOT_USERNAME = "admin"
        MONGO_INITDB_ROOT_PASSWORD = var.admin_password
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = ["dns"]
        args        = ["mongod", "--auth", "--replSet", var.replicaset_name]
        dns_servers = var.service_dns
        volumes = compact([
          var.data == "" ? "" : format("%s:/data/db", var.data)
        ])
      }
    } // task "daemon"
  }   // group "mongodb"
}     // job "mongodb"
