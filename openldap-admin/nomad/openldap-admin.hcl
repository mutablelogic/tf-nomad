
// OpenLDAP user adminstrator
// Docker Image: https://github.com/wheelybird/ldap-user-manager

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
  default     = "openldap-admin"
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

variable "docker_image" {
  description = "Docker image"
  type        = string
}

variable "docker_always_pull" {
  description = "Pull docker image on every job restart"
  type        = bool
  default     = false
}

variable "debug" {
  description = "Debug output"
  type        = bool
  default     = false
}

///////////////////////////////////////////////////////////////////////////////

variable "port" {
  description = "Port for plaintext connections"
  type        = number
  default     = 5000
}

variable "url" {
  description = "LDAP server url"
  type        = string
}

variable "basedn" {
  description = "LDAP base distinguished name"
  type        = string
}

variable "admin_password" {
  description = "LDAP admin password"
  type        = string
}

variable "admin_group" {
  description = "LDAP admins group"
  type        = string
  default     = "admin"
}

variable "organization" {
  description = "Organization name"
  type        = string
}

variable "domain" {
  description = "Organization domain"
  type        = string
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "openldap-admin" {
  type        = var.service_type
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "openldap-admin" {
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
      port "http" {
        static = var.port
        to     = 5000
      }
    }

    service {
      tags     = ["openldap-admin", "http"]
      name     = var.service_name
      port     = "http"
      provider = var.service_provider
    }

    task "daemon" {
      driver = "docker"

      env {
        LDAP_URI              = var.url
        LDAP_BASE_DN          = var.basedn
        LDAP_ADMIN_BIND_DN    = format("cn=admin,%s", var.basedn)
        LDAP_ADMIN_BIND_PWD   = var.admin_password
        LDAP_ADMINS_GROUP     = var.admin_group
        LDAP_USER_OU          = "users"
        LDAP_GROUP_OU         = "groups"
        NO_HTTPS              = "true"
        SERVER_PORT           = "5000"
        ORGANISATION_NAME     = var.organization
        SITE_NAME             = var.organization
        EMAIL_DOMAIN          = var.domain
        LDAP_DEBUG            = var.debug ? "true" : "false"
        USERNAME_REGEX        = "^[a-z][a-zA-Z0-9._-]{2,32}$"
        ACCEPT_WEAK_PASSWORDS = "true"
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = ["http"]
        dns_servers = var.service_dns
      }

    } // task "daemon"
  }   // group "openldap-admin"
}     // job "openldap-admin"
