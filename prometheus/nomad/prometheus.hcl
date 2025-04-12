
// OpenLDAP server
// Docker Image: https://hub.docker.com/r/prom/prometheus/

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

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "prometheus"
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

variable "docker_always_pull" {
  description = "Pull docker image on every job restart"
  type        = bool
  default     = false
}

///////////////////////////////////////////////////////////////////////////////

variable "hosts" {
  description = "host constraint for the job"
  type        = list(string)
  default     = []
}

variable "port" {
  description = "Port for connections"
  type        = number
  default     = 9090
}

variable "data" {
  description = "Data persistence directory"
  type        = string
  default     = ""
}

variable "configs" {
  description = "Configuration files"
  type        = map(string)
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "prometheus" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "prometheus" {
    count = length(var.hosts)

    constraint {
      attribute = node.unique.name
      operator  = "set_contains_any"
      value     = join(",", var.hosts)
    }

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    network {
      port "prometheus" {
        static = var.port
        to     = 9090
      }
    }

    service {
      tags     = ["prometheus"]
      name     = var.service_name
      port     = "prometheus"
      provider = var.service_provider
    }

    ephemeral_disk {
      migrate = false
    }

    task "server" {
      driver = "docker"

      resources {
        memory = 512
      }

      dynamic "template" {
        for_each = var.configs
        content {
          destination = format("${NOMAD_TASK_DIR}/%s",template.key)
          data        = template.value
        }
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = ["prometheus"]
        dns_servers = var.service_dns
        volumes = compact([
          var.data == "" ? "" : format("%s:/prometheus", var.data),
          "local:/etc/prometheus",
        ])
      }

    } // task "server"
  }   // group "prometheus"
}     // job "prometheus"
