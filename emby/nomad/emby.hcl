
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

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "emby"
}

variable "service_provider" {
  description = "Service provider (consul or nomad)"
  type        = string
  default     = "nomad"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "docker_image" {
  description = "Docker image"
  type        = string
  default     = "linuxserver/emby"
}

variable "docker_always_pull" {
  description = "Pull docker image on every job restart"
  type        = bool
  default     = false
}

variable "host" {
  description = "host constraint for emby"
  type        = string
}

variable "port" {
  description = "port for emby"
  type        = number
  default     = 8096
}

variable "data" {
  description = "data volume for persistent data"
  type        = string
  default     = "/var/lib/emby"
}

variable "media" {
  description = "media volumes for media files"
  type        = list(string)
  default     = []
}

variable "devices" {
  description = "devices"
  type        = list(string)
  default     = ["/dev/dri", "/dev/vchiq", "/dev/video10", "/dev/video11", "/dev/video12"]
}

variable "timezone" {
  description = "timezone"
  type        = string
  default     = "Europe/Berlin"
}

variable "memory" {
  description = "memory allocation"
  type        = number
  default     = 2048
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  media = [
    for i, media in var.media : format("%s:/media%s", media, i == 0 ? "" : (i + 1))
  ]
  devices = [
    for device in var.devices : {
      host_path      = device
      container_path = device
    }
  ]
  volumes = compact(flatten([
    var.data == "" ? "" : format("%s:/config", var.data),
    local.media
  ]))
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "emby" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "emby" {

    constraint {
      attribute = node.unique.name
      operator  = "="
      value     = var.host
    }

    network {
      port "emby" {
        static = var.port
        to     = 8096
      }
    }

    service {
      tags     = ["emby", "http"]
      name     = format("%s-http", var.service_name)
      port     = "emby"
      provider = var.service_provider
    }

    ephemeral_disk {
      migrate = true
    }

    task "emby" {
      driver = "docker"

      // Reserve memory
      resources {
        memory = var.memory
      }

      env {
        PUID    = "999"
        PGID    = "995"
        TZ      = var.timezone
        GIDLIST = "44,100,107"
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = ["emby"]
        dns_servers = var.service_dns
        volumes     = local.volumes
        devices     = local.devices
      }
    } // task "emby"
  }   // group "emby"
}     // job "emby"
