
// Semaphore CI/CD
// Docker Image: semaphoreui/semaphore:latest

///////////////////////////////////////////////////////////////////////////////
// VARIABLES

variable "dc" {
  description = "data centers that the job runs in"
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

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
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
  default     = 3000
}

variable "data" {
  description = "Data persistence directory"
  type        = string
  default     = ""
}

variable "admin_password" {
  description = "Password for the admin user"
  type        = string
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "semaphore" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "semaphore" {
    count = length(var.hosts)

    constraint {
      attribute = node.unique.name
      operator  = "set_contains_any"
      value     = join(",", var.hosts)
    }

    network {
      port "http" {
        static = var.port
        to     = 3000
      }
      port "postgres" {
        to = 5432
      }
    }

    service {
      tags     = ["http", "semaphore"]
      name     = "semaphore-http"
      port     = "http"
      provider = var.service_provider
    }

    task "key" {
      driver = "raw_exec"
      config {
        command = "sh"
        args    = ["-c", "head -c32 /dev/urandom | base64 > ../alloc/data/semaphore.key"]
      }
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
    }

    task "daemon" {
      driver = "docker"

      env {
        SEMAPHORE_ADMIN                 = "admin"
        SEMAPHORE_ADMIN_PASSWORD        = var.admin_password
        SEMAPHORE_ACCESS_KEY_ENCRYPTION = "testtest" //chomp(file("../alloc/data/semaphore.key"))
        ANSIBLE_HOST_KEY_CHECKING       = "false"
        SEMAPHORE_DB_DIALECT            = "bolt"
        SEMAPHORE_CONFIG_PATH           = "local"
      }

      config {
        image      = var.docker_image
        force_pull = var.docker_always_pull
        volumes = compact([
          format("%s:/tmp/semaphore", var.data == "" ? "../alloc/data" : var.data)
        ])
        ports = ["http"]
      }

    } // task "daemon"

  } // group "semaphore"

} // job "semaphore"
