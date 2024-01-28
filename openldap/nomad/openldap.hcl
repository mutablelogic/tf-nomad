
// OpenLDAP server
// Docker Image: https://bitnami.com/stack/openldap

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
  default     = "coredns-dns"
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

///////////////////////////////////////////////////////////////////////////////

variable "port" {
  description = "Port for plaintext connections"
  type        = number
  default     = 389
}

variable "data" {
  description = "Data persistence directory"
  type        = string
  default     = ""
}

variable "ldif" {
  description = "Custom LDIF rules, optional"
  type        = map(string)
}

variable "schema" {
  description = "Custom schemas, optional"
  type        = map(string)
}

variable "extra_schemas" {
  description = "Extra schemas, optional"
  type        = string
  default     = "cosine,inetorgperson"
}

variable "admin_password" {
  description = "LDAP admin password"
  type        = string
}

variable "basedn" {
  description = "Distinguished name"
  type        = string
}

variable "organization" {
  description = "Organization name"
  type        = string
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  ldif_path   = format("%s/data/ldif",NOMAD_ALLOC_DIR)
  schema_path   = format("%s/data/schema",NOMAD_ALLOC_DIR)
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "openldap" {
  type        = var.service_type
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "openldap" {
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
      port "ldap" {
        static = var.port
        to     = 389
      }
    }

    service {
      tags     = ["openldap", "ldap"]
      name     = var.service_name
      port     = "ldap"
      provider = var.service_provider
    }

    task "daemon" {
      driver = "docker"
      user   = "root"

      // Metadata for ldif and schema templates
      meta {
        basedn       = var.basedn
        organization = var.organization
        users        = "users"
        groups       = "groups"
      }

      // LDIF templates
      dynamic "template" {
        for_each = var.ldif
        content {
          destination = "${local.ldif_path}/${template.key}.ldif"
          data        = template.value
        }
      }

      // Schema templates
      dynamic "template" {
        for_each = var.schema
        content {
          destination = "${local.schema_path}/${template.key}.ldif"
          data        = template.value
        }
      }

      env {
        LDAP_ADMIN_USERNAME     = "admin"
        LDAP_ADMIN_PASSWORD     = var.admin_password
        LDAP_PORT_NUMBER        = NOMAD_PORT_ldap
        LDAP_ROOT               = var.basedn
        LDAP_ADD_SCHEMAS        = var.extra_schemas == "" ? "no" : "yes"
        LDAP_EXTRA_SCHEMAS      = var.extra_schemas
        LDAP_SKIP_DEFAULT_TREE  = "yes"
        LDAP_CUSTOM_LDIF_DIR    = local.ldif_path
        LDAP_CUSTOM_SCHEMA_DIR  = local.schema_path
        LDAP_CONFIGURE_PPOLICY  = "yes"
        LDAP_ALLOW_ANON_BINDING = "no"
        BITNAMI_DEBUG           = "true"
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = ["ldap"]
        dns_servers = var.service_dns
        volumes = compact([
          var.data == "" ? "" : format("%s:/bitnami/openldap", var.data),
        ])
      }

    } // task "daemon"
  }   // group "openldap"
}     // job "openldap"
