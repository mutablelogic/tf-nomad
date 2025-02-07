
// llm
// docker pull ghcr.io/mutablelogic/go-llm

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

variable "hosts" {
  description = "hosts to deploy on"
  type        = list(string)
  default     = []
}

variable "debug" {
  type        = bool
  description = "Debugging log output"
  default     = false
}

variable "model" {
  type        = string
  description = "Model name"
}

variable "timeout" {
  type        = string
  description = "Client timeout"
}

variable "env" {
  type        = map(string)
  description = "Environment variables"
  default     = {}
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "llm" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "service" {
    count = length(var.hosts)

    constraint {
      attribute = node.unique.name
      operator  = "set_contains_any"
      value     = join(",", var.hosts)
    }

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    task "daemon" {
      driver = "docker"

      resources {
        cpu    = 500
        memory = 256
      }

      dynamic "env" {
        for_each = var.env
        content {
          name  = env.key
          value = env.value
        }
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        dns_servers = var.service_dns
        args = compact([
          "chat-2",
          var.model,
          var.timeout == "" ? "" : format("--timeout=%s", var.timeout),
          var.debug ? "--debug" : "",
        ])
      }

    } // task "daemon"
  }   // group "service"
}     // job "llm"
