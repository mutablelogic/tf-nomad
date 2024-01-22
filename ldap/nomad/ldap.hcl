
// LDAP server
// Docker Image: https://bitnami.com/stack/openldap

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
  default     = 389
}

variable "data" {
  description = "Data persistence directory"
  type        = string
}

variable "admin_password" {
  description = "LDAP admin password"
  type        = string
}

variable "basedn" {
  description = "Distinguished name"
  type        = string
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "ldap" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

/////////////////////////////////////////////////////////////////////////////////

  group "ldap" {
    count = length(var.hosts)

    constraint {
      attribute = node.unique.name
      operator  = "set_contains_any"
      value     = join(",", var.hosts)
    }

    network {
      port "ldap" {
        static = var.port
        to     = 389
      }
    }

    service {
      tags     = ["ldap"]
      name     = "ldap"
      port     = "ldap"
      provider = var.service_provider
    }

    env {
      LDAP_ADMIN_USERNAME    = "admin"
      LDAP_ADMIN_PASSWORD    = var.admin_password
      LDAP_PORT_NUMBER       = "${NOMAD_PORT_ldap}"
      LDAP_ROOT              = var.basedn
      LDAP_ADD_SCHEMAS       = "yes"
      LDAP_EXTRA_SCHEMAS     = "cosine, inetorgperson, nis"
      LDAP_SKIP_DEFAULT_TREE = "yes"
    }

    task "daemon" {
      driver = "docker"

      config {
        image      = var.docker_image
        force_pull = var.docker_always_pull
        volumes = compact([
          format("%s:/var/lib/openldap", var.data == "" ? "/alloc/data" : var.data)
        ])
        ports = ["ldap"]
      }
    } // task "daemon"
  } // group "ldap"
} // job "ldap"

