
// ollama LLM
// Docker Image: ollama/ollama

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

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "ollama"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "docker_image" {
  description = "Docker image"
  type        = string
  default     = "ollama/ollama:latest"
}

variable "docker_runtime" {
  description = "Docker runtime"
  type        = string
  default     = ""
}

variable "docker_image_webui" {
  description = "Docker image"
  type        = string
  default     = "ghcr.io/open-webui/open-webui:main"
}

variable "docker_always_pull" {
  description = "Pull docker image on every job restart"
  type        = bool
  default     = false
}

///////////////////////////////////////////////////////////////////////////////

variable "hosts" {
  description = "List of hosts to deploy on. If empty, one allocation will be created"
  type        = list(string)
  default     = []
}

variable "port" {
  description = "Ollama port to expose"
  type        = number
  default     = 11434
}

variable "data" {
  description = "Persistent data path"
  type        = string
  default     = ""
}

variable "devices" {
  description = "Devices to expose"
  type        = list(string)
  default     = []
}

variable "hosts_webui" {
  description = "List of hosts to deploy webui on. If empty, one allocation will be created"
  type        = list(string)
  default     = []
}

variable "port_webui" {
  description = "WebUI port to expose"
  type        = number
  default     = 11435
}

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
  default     = ""
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  devices = [
    for device in var.devices : {
      host_path      = device
      container_path = device
    }
  ]
  volumes = compact([
    var.data != "" ? format("%s:/root/.ollama", var.data) : null,
  ])
  volumes_webui = compact([
    var.data != "" ? format("%s:/app/backend/data", var.data) : null,
  ])
  ollama_service = format("http://%s-http.%s.nomad.:%s", var.service_name, var.namespace, var.port)
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "ollama" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "ollama" {
    count = var.docker_image_webui == "" ? 0 : (length(var.hosts) == 0 ? 1 : length(var.hosts))

    dynamic "constraint" {
      for_each = length(var.hosts) == 0 ? [] : [join(",", var.hosts)]
      content {
        attribute = node.unique.name
        operator  = "set_contains_any"
        value     = constraint.value
      }
    }

    network {
      port "http" {
        static = var.port
        to     = 11434
      }
    }

    service {
      tags     = [var.service_name, "http"]
      name     = format("%s-%s", var.service_name, "http")
      port     = "http"
      provider = var.service_provider
    }

    task "server" {
      driver = "docker"

      config {
        image       = var.docker_image
        runtime     = var.docker_runtime
        force_pull  = var.docker_always_pull
        ports       = ["http"]
        dns_servers = var.service_dns
        volumes     = local.volumes
        devices     = local.devices
      }

      resources {
        memory = 2048
      }
    } // task "server"
  }   // group "ollama"


  /////////////////////////////////////////////////////////////////////////////////

  group "ollama-webui" {
    count = length(var.hosts_webui) == 0 ? 1 : length(var.hosts_webui)

    dynamic "constraint" {
      for_each = length(var.hosts_webui) == 0 ? [] : [join(",", var.hosts_webui)]
      content {
        attribute = node.unique.name
        operator  = "set_contains_any"
        value     = constraint.value
      }
    }

    network {
      port "http" {
        static = var.port_webui
        to     = 8080
      }
    }

    service {
      tags     = [var.service_name, "webui", "http"]
      name     = format("%s-webui-%s", var.service_name, "http")
      port     = "http"
      provider = var.service_provider
    }

    task "server" {
      driver = "docker"

      // Reserve 2048MB of memory
      resources {
        memory = 2048
      }

      env {
        OLLAMA_BASE_URL      = local.ollama_service
        OPENAI_API_KEYS      = var.openai_api_key
        OPENAI_API_BASE_URLS = var.openai_api_key == "" ? "" : "https://api.openai.com/v1"
      }

      config {
        image       = var.docker_image_webui
        force_pull  = var.docker_always_pull
        ports       = ["http"]
        dns_servers = var.service_dns
        volumes     = local.volumes_webui
      }
    } // task "server"
  }   // group "ollama-webui"  
}     // job "ollama"
