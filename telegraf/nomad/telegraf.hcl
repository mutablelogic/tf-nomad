
// telegraf time-series metrics collector
// Docker Image: https://hub.docker.com/_/telegraf

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
  default     = "telegraf"
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

variable "hosts" {
  description = "host constraint for the job"
  type        = list(string)
  default     = []
}

variable "outputs" {
  description = "Configuration outputs"
  type        = map(map(string))
}

variable "inputs" {
  description = "Configuration inputs"
  type        = map(map(string))
}

variable "ports" {
  description = "Ports to expose"
  type        = map(number)
  default = {}
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "telegraf-${ name }" {
  type        = var.service_type
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "telegraf" {
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
        labels   = [ "$${port.key}" ]
        content {
          static = port.value
          to     = port.value
        }
      }
    }

    dynamic "service" {
      for_each = var.ports
      content {
        tags     = [var.service_name, service.key]
        name     = format("%s-%s",var.service_name, service.key)
        port     = service.key
        provider = var.service_provider
      }
    }

    task "daemon" {
      driver = "docker"

      // Global Tags Template
      template {
        destination = "local/config/global_tags.conf"
        data        = <<-EOF
        [global_tags]
        dc = "$${NOMAD_DC}"
        namespace = "$${NOMAD_NAMESPACE}"
        region = "$${NOMAD_REGION}"
        EOF
      }

      // Agent templates
      template {
        destination = "local/config/agent.conf"
        data        = <<-EOF
        [agent]
        interval = "10s"
        round_interval = true
        metric_batch_size = 1000
        metric_buffer_limit = 10000
        collection_jitter = "0s"
        flush_interval = "10s"
        flush_jitter = "0s"
        precision = ""
        debug = false
        quiet = false
        logtarget = "stderr"
        hostname = "$${HOST_NAME}"
        omit_hostname = false
        EOF
      }

      // Outputs templates
      dynamic "template" {
        for_each = var.outputs
        content {
          destination     = "local/config/output_$${template.key}.conf"
          left_delimiter  = "{{{"
          right_delimiter = "}}}"
          data            = <<-EOF
          [[outputs.$${template.key}]]
          $${join("\n", [for k, v in template.value : "$${k} = $${v}"])}
          EOF
        }
      }

      // Inputs templates
      dynamic "template" {
        for_each = var.inputs
        content {
          destination = "local/config/input_$${template.key}.conf"
          data        = <<-EOF
          [[inputs.$${template.key}]]
          $${join("\n", [for k, v in template.value : "$${k} = $${v}"])}
          EOF
        }
      }

      env {
        HOST_MOUNT_PREFIX = "/hostfs"
        HOST_ETC          = "/hostfs/etc"
        HOST_PROC         = "/hostfs/proc"
        HOST_SYS          = "/hostfs/sys"
        HOST_VAR          = "/hostfs/var"
        HOST_RUN          = "/hostfs/run"
        HOST_NAME         = node.unique.name
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        dns_servers = var.service_dns
        ports       = keys(var.ports)
        volumes = compact([
          "/:/hostfs:ro",
          "local/config:/etc/telegraf",
        ])
        args = [
          "--config-directory=/etc/telegraf"
        ]
        privileged = true
      }

    } // task "daemon"
  }   // group "telegraf"
}     // job "telegraf"
