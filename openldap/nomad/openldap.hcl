
// OpenLDAP server
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
  description = "Data persistence directory, required"
  type        = string
}

variable "ldif" {
  description = "Path to custom LDIF files, optional"
  type        = string
}

variable "schema" {
  description = "Path to custom schema files, optional"
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
// LOCALS

locals {
  data_path   = "/bitnami/openldap"
  ldif_path   = var.ldif == "" ? "" : "/ldap/ldif"
  schema_path = var.schema == "" ? "" : "/ldap/schema"
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "openldap" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "openldap" {
    count = length(var.hosts) == 0 ? 1 : length(var.hosts)

    dynamic "constraint" {
      for_each = length(var.hosts) == 0 ? [] : [join(",", var.hosts)]
      content {
        attribute = node.unique.name
        operator  = "set_contains_any"
        value     = constraint.value
      }
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

    ephemeral_disk {
      migrate = true
    }

    task "daemon" {
      driver = "docker"

      config {
        image      = var.docker_image
        force_pull = var.docker_always_pull
        volumes = compact([
          local.ldif_path == "" ? "" : format("%s:%s", var.ldif, local.ldif_path),
          local.schema_path == "" ? "" : format("%s:%s", var.schema, local.schema_path)
        ])
        ports = ["ldap"]
      }

      // TODO: /bitnami/openldap should be /alloc/data when var.data is empty

      env {
        LDAP_ADMIN_USERNAME    = "admin"
        LDAP_ADMIN_PASSWORD    = var.admin_password
        LDAP_PORT_NUMBER       = NOMAD_PORT_ldap
        LDAP_ROOT              = var.basedn
        LDAP_ADD_SCHEMAS       = "yes"
        LDAP_EXTRA_SCHEMAS     = "cosine, inetorgperson, nis"
        LDAP_SKIP_DEFAULT_TREE = "yes"
        LDAP_CUSTOM_LDIF_DIR   = local.ldif_path
        LDAP_CUSTOM_SCHEMA_DIR = local.schema_path
      }

    } // task "daemon"
  }   // group "openldap"
}     // job "openldap"
