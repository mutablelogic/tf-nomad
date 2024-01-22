
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

variable "hosts" {
  description = "host constraint for the job"
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

variable "outputs" {
  description = "Configuration outputs"
  type        = map(map(string))
}

variable "inputs" {
  description = "Configuration inputs"
  type        = map(map(string))
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "telegraf" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "telegraf" {
    count = length(var.hosts)

    constraint {
      attribute = node.unique.name
      operator  = "set_contains_any"
      value     = join(",", var.hosts)
    }

    task "daemon" {
      driver = "docker"

      // Global Tags Template
      template {
        destination = "local/config/global_tags.conf"
        data        = <<-EOF

        [global_tags]
        dc = "${NOMAD_DC}"
        namespace = "${NOMAD_NAMESPACE}"
        EOF
      }

      // Outputs templates
      dynamic "template" {
        for_each = var.outputs
        content {
          destination = "local/config/output_${template.key}.conf"
          data        = <<-EOF
          [[outputs.${template.key}]]
          ${join("\n", [for k, v in template.value : "${k} = ${v}"])}
          EOF
        }
      }

      // Inputs templates
      dynamic "template" {
        for_each = var.inputs
        content {
          destination = "local/config/input_${template.key}.conf"
          data        = <<-EOF
          [[inputs.${template.key}]]
          ${join("\n", [for k, v in template.value : "${k} = ${v}"])}
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
        image      = var.docker_image
        force_pull = var.docker_always_pull
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
