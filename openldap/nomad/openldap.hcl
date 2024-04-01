
// OpenLDAP server
// Docker Image: https://github.com/osixia/docker-openldap

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
  default     = "openldap-ldap"
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
  default     = 389
}

variable "tls_port" {
  description = "Port for TLS connections"
  type        = number
  default     = 636
}

variable "data" {
  description = "Data persistence directory"
  type        = string
  default     = ""
}

variable "admin_password" {
  description = "LDAP admin password"
  type        = string
}

variable "config_password" {
  description = "LDAP config password"
  type        = string
}

variable "replication_hosts" {
  description = "LDAP urls for replication"
  type        = list(string)
}

variable "organization" {
  description = "Organization name"
  type        = string
}

variable "domain" {
  description = "Organization domain"
  type        = string
}

variable "ldif" {
  description = "Custom LDIF rules, optional"
  type        = map(string)
}

variable "schema" {
  description = "Custom schemas, optional"
  type        = map(string)
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  ldif_path   = format("%s/data/ldif", NOMAD_ALLOC_DIR)
  schema_path = format("%s/data/schema", NOMAD_ALLOC_DIR)
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
      port "ldaps" {
        static = var.tls_port
        to     = 636
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

      // Metadata for ldif and schema templates
      meta {
        organization = var.organization
        domain       = "{{ LDAP_DOMAIN }}"
        basedn       = "{{ LDAP_BASE_DN }}"
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
        LDAP_DOMAIN                    = var.domain
        LDAP_ORGANISATION              = var.organization
        LDAP_ADMIN_PASSWORD            = var.admin_password
        LDAP_CONFIG_PASSWORD           = var.config_password
        LDAP_RFC2307BIS_SCHEMA         = "true"
        LDAP_REMOVE_CONFIG_AFTER_SETUP = "false"
        LDAP_SEED_INTERNAL_LDIF_PATH   = length(var.ldif) == 0 ? "" : local.ldif_path
        LDAP_SEED_INTERNAL_SCHEMA_PATH = length(var.schema) == 0 ? "" : local.schema_path
        LDAP_REPLICATION               = length(var.replication_hosts) == 0 ? "false" : "true"
        LDAP_REPLICATION_HOSTS         = length(var.replication_hosts) == 0 ? "" : format("#PYTHON2BASH:%s", jsonencode(var.replication_hosts))
        LDAP_TLS                       = "false"
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = ["ldap", "ldaps"]
        dns_servers = var.service_dns
        args        = ["--copy-service", "--loglevel", var.debug ? "debug" : "info"]
        volumes = compact([
          var.data == "" ? "" : format("%s/data:/var/lib/ldap", var.data),
          var.data == "" ? "" : format("%s/slapd.d:/etc/ldap/slapd.d", var.data),
        ])
      }

    } // task "daemon"
  }   // group "openldap"
}     // job "openldap"
