
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

variable "docker_image" {
  description = "Docker image"
  type        = string
}

variable "docker_always_pull" {
  description = "Pull docker image on every job restart"
  type        = bool
  default     = false
}

variable "masters" {
  description = "Master servers"
  type        = list(object({ ip = string, data = string, replication = string, http_port = number, grpc_port = number, metrics_port = number }))
}

variable "volumes" {
  description = "Volume servers"
  type        = list(object({ ip = string, data = string, rack = string, max = number, http_port = number, grpc_port = number, metrics_port = number }))
}

variable "filers" {
  description = "Filer servers"
  type        = list(object({ ip = string, data = string, http_port = number, grpc_port = number, metrics_port = number, s3_port = number, webdav_port = number }))
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  grpc_offset            = 10000
  master_ips             = [for master in var.masters : master.ip]
  master_addrs_http      = [for master in var.masters : format("%s:%d", master.ip, var.master_port)]
  master_addrs_http_grpc = [for master in var.masters : format("%s:%d.%d", master.ip, var.master_port, var.master_port + local.grpc_offset)]
  master_data            = { for master in var.masters : master.ip => master.data }
  master_metrics_port    = { for master in var.masters : master.ip => master.metrics_port }
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "seaweedfs" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

///////////////////////////////////////////////////////////////////////////////

  group "master" {
    count = length(var.masters)

    constraint {
      attribute = attr.unique.network.ip-address
      operator  = "set_contains_any"
      value     = join(",", local.master_ips)
    }

    network {
      mode = "host"
      port "http" {
        static = var.master_port
        to     = var.master_port
      }
      port "grpc" {
        static = var.master_port + local.grpc_offset
        to     = var.master_port + local.grpc_offset
      }
    }

    service {
      tags     = ["http", "seedweedfs", "master"]
      name     = "seaweedfs-master-http"
      port     = "http"
      provider = var.service_provider
    }

    service {
      tags     = ["grpc", "seedweedfs", "master"]
      name     = "seaweedfs-master-grpc"
      port     = "grpc"
      provider = var.service_provider
    }

    task "weed-master" {
      driver = "docker"

      config {
        image      = var.docker_image
        force_pull = var.docker_always_pull
        args = compact([
          "-logtostderr",
          "master",
          "-ip=${NOMAD_IP_http}",
          "-ip.bind=0.0.0.0",
          "-peers=${join(",", local.master_addrs_http)}",
          master_data["${NOMAD_IP_http}"] && master_data["${NOMAD_IP_http}"].data ? "-mdir=/data" : "",
          "-port=${NOMAD_PORT_http}",
          "-port.grpc=${NOMAD_PORT_grpc}"
        ])
        volumes = compact([
          master_data["${NOMAD_IP_http}"] && master_data["${NOMAD_IP_http}"].data ? format("%s:/data", var.data) : "",
        ])
        ports      = ["http", "grpc"]
        privileged = true
      }

    } // task "weed-master"

  } // group "master"

} // job "seaweedfs"
