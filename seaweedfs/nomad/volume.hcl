
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
  default     = "seaweedfs"
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

variable "ip" {
  description = "Volume server IP address"
  type        = string
}

variable "masters" {
  description = "Master server IP addresses"
  type        = list(string)
}

variable "data" {
  description = "Persistent data paths"
  type        = list(string)
}

variable "port" {
  description = "HTTP port"
  type        = number
}

variable "grpc_port" {
  description = "gRPC port"
  type        = number
  default     = 0
}

variable "metrics_port" {
  description = "Prometheus metrics port "
  type        = number
  default     = 0
}

variable "rack" {
  description = "Rack for volume server"
  type        = string
  default     = "default"
}

variable "public_url" {
  description = "Publicly accessible address"
  type        = string
  default     = ""
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  // gRPC offset if the port is not set explicitly
  grpc_offset = 10000

  // Use max=0 for each data path
  data_dir    = compact([for i, v in var.data : format("/data%s", i)])
  data_volume = compact([for i, v in var.data : v == "" ? "" : format("%s:/data%s", v, i)])
  data_max    = compact([for i in var.data : 0])
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "seaweedfs-volume-${ name }" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  ///////////////////////////////////////////////////////////////////////////////

  group "volume" {
   count = 1

    constraint {
      attribute = var.ip
      operator  = "set_contains"
      value     = "$${attr.unique.network.ip-address}"
    }

    network {
      mode = "host"

      // HTTP port is always exposed
      port "http" {
        static = var.port
        to     = var.port
      }

      // gRPC port is always exposed
      port "grpc" {
        static = var.grpc_port == 0 ? var.port + local.grpc_offset : var.grpc_port
        to     = var.grpc_port == 0 ? var.port + local.grpc_offset : var.grpc_port
      }

      // metrics port is only exposed if the volume is configured to use it
      dynamic "port" {
        for_each = var.metrics_port > 0 ? [1] : []
        labels   = ["metrics"]
        content {
          static = var.metrics_port
          to     = var.metrics_port
        }
      }
    }

    service {
      tags     = ["http", var.service_name, "volume"]
      name     = format("%s-volume-http", var.service_name)
      port     = "http"
      provider = var.service_provider
    }

    service {
      tags     = ["grpc", var.service_name, "volume"]
      name     = format("%s-volume-grpc", var.service_name)
      port     = "grpc"
      provider = var.service_provider
    }

    dynamic "service" {
      for_each = var.metrics_port > 0 ? [1] : []
      content {
        tags     = ["metrics", var.service_name, "volume"]
        name     = format("%s-volume-metrics", var.service_name)
        port     = "metrics"
        provider = var.service_provider
      }
    }

    task "volume" {    
      driver = "docker"
      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        dns_servers = var.service_dns
        args = compact([
          "-logtostderr",
          "volume",
          "-ip=$${attr.unique.network.ip-address}",
          "-ip.bind=0.0.0.0",
          "-port=$${NOMAD_PORT_http}",
          "-port.grpc=$${NOMAD_PORT_grpc}",
          format("-mserver=%s", join(",", var.masters)),
          format("-dir=%s", join(",", local.data_dir)),
          format("-max=%s", join(",", local.data_max)),
          var.metrics_port == 0 ? "" : "-metricsPort=$${NOMAD_PORT_metrics}",
          "-dataCenter=$${NOMAD_DC}",
          "-rack=$${var.rack}",
          var.public_url == "" ? "" : "-publicUrl=$${var.public_url}"
        ])
        volumes = local.data_volume
        ports = compact([
          "http",
          "grpc",
          var.metrics_port > 0 ? "metrics" : "",
        ])
      }
    } // task "volume"
  }   // group "volume"

  ///////////////////////////////////////////////////////////////////////////////

} // job "seaweedfs"
