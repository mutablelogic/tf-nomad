
// nginx web server
// Docker Image: nginx

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
  default     = "grafana-http"
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

variable "ports" {
  description = "Ports to expose"
  type        = map(number)
}

variable "config" {
  description = "Main configuration for nginx"
  type        = string
}

variable "mimetypes" {
  description = "Mimetype configuration for nginx"
  type        = string
}

variable "servers" {
  description = "Servers configuration for nginx"
  type = list(object({
    name = string
    data = string
  }))
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "nginx" {
  type        = var.service_type
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "nginx" {
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
        name     = format("nginx-%s", service.key)
        port     = service.key
        provider = var.service_provider
      }
    }

    ephemeral_disk {
      migrate = true
    }

    task "server" {
      driver = "docker"

      meta {
        task_dir  = NOMAD_TASK_DIR
        alloc_dir = NOMAD_ALLOC_DIR
      }

      template {
        data        = var.config
        destination = format("%s/config/nginx.conf", NOMAD_TASK_DIR)
      }

      template {
        data        = var.mimetypes
        destination = format("%s/config/mimetypes.conf", NOMAD_TASK_DIR)
      }

      // Server templates
      dynamic "template" {
        for_each = var.servers
        content {
          destination = format("%s/config/conf.d/%s.conf", NOMAD_TASK_DIR, template.value.name)
          data        = template.value.data
        }
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = keys(var.ports)
        dns_servers = var.service_dns
        args        = ["nginx", "-c", "${NOMAD_TASK_DIR}/config/nginx.conf", "-g", "daemon off;"]
      }

    } // task "server"
  } // group "nginx"
} // job "nginx"
