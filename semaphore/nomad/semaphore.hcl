
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

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "semaphore"
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

variable "hosts" {
  description = "host constraint for the job"
  type        = list(string)
  default     = []
}

variable "port" {
  description = "Port for plaintext connections"
  type        = number
  default     = 3000
}

variable "timezone" {
  description = "Timezone"
  type        = string
  default     = "Europe/Berlin"
}

variable "admin_user" {
  description = "Admin user"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Password for the admin user"
  type        = string
}

variable "db_type" {
  description = "Database type"
  type        = string
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}

variable "ldap_host" {
  description = "LDAP host"
  type        = string
}

variable "ldap_port" {
  description = "LDAP port"
  type        = number
}

variable "ldap_tls" {
  description = "LDAP TLS"
  type        = bool
  default     = true
}

variable "ldap_dn_bind" {
  description = "LDAP bind DN"
  type        = string
}

variable "ldap_password" {
  description = "LDAP password"
  type        = string
}

variable "ldap_dn_search" {
  description = "LDAP search DN"
  type        = string
}

variable "ldap_filter_search" {
  description = "LDAP search filter"
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
    count = length(var.hosts) == 0 ? 1 : length(var.hosts)

    dynamic "constraint" {
      for_each = length(var.hosts) == 0 ? [] : [1]
      content {
        attribute = node.unique.name
        operator  = "set_contains_any"
        value     = join(",", var.hosts)
      }
    }

    network {
      port "semaphore" {
        static = var.port
        to     = 3000
      }
    }

    service {
      tags     = ["http", "semaphore"]
      name     = "semaphore-http"
      port     = "semaphore"
      provider = var.service_provider
    }

    task "semaphore" {
      driver = "docker"

      env {
        SEMAPHORE_ADMIN                 = var.admin_user
        SEMAPHORE_ADMIN_PASSWORD        = var.admin_password
        SEMAPHORE_ACCESS_KEY_ENCRYPTION = "G4/IFe7uUIx72Fl47SN6a/HuSo4G1YZwJ2xdNQIEdxM="
        SEMAPHORE_DB_DIALECT            = var.db_type
        SEMAPHORE_DB_HOST               = var.db_host
        SEMAPHORE_DB_PORT               = var.db_port
        SEMAPHORE_DB_NAME               = var.db_name
        SEMAPHORE_DB_USER               = var.db_user
        SEMAPHORE_DB_PASS               = var.db_password
        SEMAPHORE_PLAYBOOK_PATH         = "/data"
        SEMAPHORE_LDAP_ACTIVATED        = var.ldap_host == "" ? "no" : "yes"
        SEMAPHORE_LDAP_HOST             = var.ldap_host
        SEMAPHORE_LDAP_PORT             = var.ldap_port
        SEMAPHORE_LDAP_NEEDTLS          = var.ldap_tls ? "yes" : "no"
        SEMAPHORE_LDAP_DN_BIND          = var.ldap_dn_bind
        SEMAPHORE_LDAP_PASSWORD         = var.ldap_password
        SEMAPHORE_LDAP_DN_SEARCH        = var.ldap_dn_search
        SEMAPHORE_LDAP_FILTER_SEARCH    = var.ldap_filter_search
        TZ                              = var.timezone
        ANSIBLE_HOST_KEY_CHECKING       = "False"
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        dns_servers = var.service_dns
        ports       = ["semaphore"]
      }

    } // task "semaphore"

  } // group "semaphore"

} // job "semaphore"
