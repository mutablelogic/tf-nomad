
// nginx web server with SSL
// Docker Image: lscr.io/linuxserver/swag

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
  description = "List of hosts to deploy on. If empty, one allocation will be created"
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
  default     = "nginx-ssl"
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

variable "ports" {
  description = "Ports to expose"
  type        = map(number)
  default = {
    "http"  = 80,
    "https" = 443
  }
}

variable "configs" {
  description = "Main configurations for nginx"
  type        = map(string)
}

variable "servers" {
  description = "Servers configuration for nginx"
  type        = map(string)
}

variable "timezone" {
  description = "Timezone"
  type        = string
  default     = "Europe/Berlin"
}

variable "zone" {
  description = "zone"
  type        = string
}

variable "email" {
  description = "Email address for zone administator"
  type        = string
  default     = ""
}

variable "subdomains" {
  description = "Subdomains"
  type        = list(string)
}

variable "dns_validation" {
  description = "DNS validation type (http, cloudflare, duckdns)"
  type        = string
  default     = "http"
}

variable "cloudflare_api_key" {
  description = "Cloudflare API key"
  type        = string
  default     = ""
}

variable "duckdns_api_key" {
  description = "duckdns API key"
  type        = string
  default     = ""
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "nginx-ssl" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "nginx" {
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
      dynamic "port" {
        for_each = var.ports
        labels   = ["${port.key}"]
        content {
          static = port.value
          to     = port.value
        }
      }
    }

    dynamic "service" {
      for_each = var.ports
      content {
        tags     = ["nginx", "${service.key}"]
        name     = format("%s-%s", var.service_name, service.key)
        port     = service.key
        provider = var.service_provider
      }
    }

    task "server" {
      driver = "docker"

      meta {
        task_dir           = NOMAD_TASK_DIR
        alloc_dir          = NOMAD_ALLOC_DIR
        zone               = var.zone
        cert_dir           = format("/config/etc/letsencrypt/live/%s", var.zone)
        cloudflare_api_key = var.cloudflare_api_key
        duckdns_api_key    = var.duckdns_api_key
      }

      // Main configurations
      dynamic "template" {
        for_each = var.configs
        content {
          destination = format("${NOMAD_TASK_DIR}/nginx/%s", template.key)
          data        = template.value
        }
      }

      // Cloudflare DNS configuration
      dynamic "template" {
        for_each = var.dns_validation == "cloudflare" ? [1] : []
        content {
          destination = "${NOMAD_TASK_DIR}/dns-conf/cloudflare.ini"
          data        = <<-EOT
            dns_cloudflare_api_token = {{ env "NOMAD_META_cloudflare_api_key" }}
          EOT
        }
      }

      // DuckDNS DNS configuration
      dynamic "template" {
        for_each = var.dns_validation == "duckdns" ? [1] : []
        content {
          destination = "${NOMAD_TASK_DIR}/dns-conf/duckdns.ini"
          data        = <<-EOT
            dns_duckdns_token = {{ env "NOMAD_META_duckdns_api_key" }}
          EOT
        }
      }

      // Server templates
      dynamic "template" {
        for_each = var.servers
        content {
          destination = format("${NOMAD_TASK_DIR}/nginx/conf.d/%s.conf", template.key)
          data        = template.value
        }
      }

      env {
        PUID         = 1000
        PGID         = 1000
        TZ           = var.timezone
        URL          = var.zone
        EMAIL        = var.email
        CERTPROVIDER = "letsencrypt"
        SUBDOMAINS   = length(var.subdomains) == 0 ? "wildcard" : join(",", var.subdomains)
        VALIDATION   = var.dns_validation == "http" ? "http" : "dns"
        DNSPLUGIN    = var.dns_validation == "http" ? "" : var.dns_validation
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = keys(var.ports)
        dns_servers = var.service_dns
        volumes = [
          "local:/config"
        ]
      }

    } // task "server"
  }   // group "nginx"
}     // job "nginx"
