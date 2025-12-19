
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

variable "name" {
  description = "Github runner name"
  type        = string
  default     = ""
}

variable "group" {
  description = "Github runner group"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Github runner labels"
  type        = list(string)
  default     = []
}

variable "data" {
  description = "Data persistence directory, optional"
  type        = string
  default     = ""
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  DATA       = var.data == "" ? "${NOMAD_ALLOC_DIR}/data" : var.data
  TOKEN_PATH = "${NOMAD_ALLOC_DIR}/data/token.txt"
  NAME       = var.name == "" ? node.unique.name : var.name
  LABELS     = join(",", var.labels)
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

    constraint {
      distinct_hosts = true
    }

    // auth task runs to obtain a runner token
    task "auth" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      config {
        image       = "curlimages/curl"
        dns_servers = var.service_dns
        args = [
          "sh",
          "-c",
          <<-EOF
            RESPONSE=$(curl -s -X "POST" -H "Authorization: token ${var.access_token}" https://api.github.com/orgs/${var.organization}/actions/runners/registration-token)
            echo "API Response: $RESPONSE" >&2
            TOKEN=$(echo "$RESPONSE" | awk -F\" '$2 ~ /token/ { print $4; exit }')
            echo "Extracted token length: $${#TOKEN}" >&2
            if [ -z "$TOKEN" ]; then
              echo "ERROR: Failed to extract token from response" >&2
              exit 1
            fi
            echo "$TOKEN" > ${local.TOKEN_PATH}
          EOF
        ]
      }
    } // task "auth"

    // runner task uses the token to create the config then run the runner
    task "runner" {
      driver = "docker"

      // Reserve 1GB of memory
      resources {
        memory = 1024
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        dns_servers = var.service_dns
        privileged  = true
        userns_mode = "host"
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
        ]
        args = [
          "sh",
          "-c",
          <<-EOF
            TOKEN=$(cat ${local.TOKEN_PATH} 2>/dev/null)
            if [ -z "$TOKEN" ]; then
              echo "ERROR: Token file is empty or missing" >&2
              cat ${local.TOKEN_PATH} >&2
              exit 1
            fi
            echo "Token length: $${#TOKEN}"
            ./config.sh \
              --work "${local.DATA}" \
              --name "${local.NAME}" \
              --runnergroup "${var.group}" \
              --labels "${local.LABELS},${node.unique.name}" \
              --url "https://github.com/${var.organization}" \
              --token "$TOKEN" \
              --unattended \
              --replace \
            && ./run.sh 
          EOF
        ]
      }
    } // task "runner"
  }   // group "github-action-runner"
}     // job "github-action-runner"
