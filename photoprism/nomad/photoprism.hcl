
// photoprism docker Image: photoprism/photoprism:latest
// mariadb docker Image: mariadb:11

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

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "photoprism"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "docker_image" {
  description = "Docker image"
  type        = string
  default    = "photoprism/photoprism:latest"
}

variable "docker_image_mariadb" {
  description = "Docker image"
  type        = string
  default = "mariadb:11"
}

variable "docker_always_pull" {
  description = "Pull docker image on every job restart"
  type        = bool
  default     = false
}

variable "host" {
  description = "host constraint for photoprism"
  type        = string
}

variable "mariadb_host" {
  description = "host for mariadb"
  type        = string
}

variable "mariadb_port" {
  description = "port for mariadb"
  type        = number
  default     = 3306
}

variable "mariadb_data" {
  description = "persistent data volume for mariadb"
  type        = string
}

variable "mariadb_database" {
  description = "database name for mariadb"
  type        = string
  default = "photoprism"
}

variable "mariadb_user" {
  description = "database user for mariadb"
  type        = string
  default = "photoprism"
}

variable "mariadb_password" {
  description = "database password for mariadb"
  type        = string
}

variable "mariadb_root_password" {
  description = "root password for mariadb"
  type        = string
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "photoprism" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "mariadb" {

    constraint {
      attribute = node.unique.name
      operator  = "="
      value     = var.mariadb_host
    }

    network {
      port "mysql" {
        static = var.mariadb_port
        to     = 3306
      }
    }

    service {
      tags     = [ "mysql", "mariadb" ]
      name     = var.service_name
      port     = "mysql"
      provider = var.service_provider
    }

    ephemeral_disk {
      migrate = true
    }

    task "mariadb" {
      driver = "docker"

      env {
        MARIADB_AUTO_UPGRADE = "1"
        MARIADB_INITDB_SKIP_TZINFO = "1"
        MARIADB_DATABASE = var.mariadb_database
        MARIADB_USER = var.mariadb_user
        MARIADB_PASSWORD = var.mariadb_password
        MARIADB_ROOT_PASSWORD = var.mariadb_root_password
      }

      config {
        image       = var.docker_image_mariadb
        force_pull  = var.docker_always_pull
        ports       = [ "mysql" ]
        dns_servers = var.service_dns
        volumes = compact([
          var.mariadb_data == "" ? "" : format("%s:/var/lib/mysql", var.mariadb_data)
        ])
      }
    }
  }   // group "mariadb"
}     // job "photoprism"
