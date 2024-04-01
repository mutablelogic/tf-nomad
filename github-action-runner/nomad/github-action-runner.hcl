
// github action runner
// Docker Image: ghcr.io/actions/actions-runner

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

variable "access_token" {
  description = "Github access token"
  type        = string
}

variable "organization" {
  description = "Github organization"
  type        = string
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  TOKEN_PATH = "${NOMAD_ALLOC_DIR}/data/token.txt"
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "github-action-runner" {
  type        = var.service_type
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "github-action-runner" {
    count = (length(var.hosts) == 0 || var.service_type == "system") ? 1 : length(var.hosts)

    dynamic "constraint" {
      for_each = length(var.hosts) == 0 ? [] : [join(",", var.hosts)]
      content {
        attribute = node.unique.name
        operator  = "set_contains_any"
        value     = constraint.value
      }
    }

    // token task runs to obtain a runner token
    task "token" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      env {
        ACCESS_TOKEN = var.access_token
        ORGANIZATION = var.organization
      }

      config {
        image       = "curlimages/curl"
        dns_servers = var.service_dns
        args = [
          "sh", 
          "-c",
          "curl -s -X \"POST\" -H \"Authorization: token ${ACCESS_TOKEN}\" https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token > ${TOKEN_PATH}"
        ]
      }
    } // task "token"
  }   // group "grafana"
}     // job "grafana"
