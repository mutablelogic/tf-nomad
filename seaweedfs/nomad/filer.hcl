
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
  description = "Filer server IP address"
  type        = string
}

variable "masters" {
  description = "Master server IP addresses"
  type        = list(string)
}

variable "data" {
  description = "Persistent data path"
  type        = string
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

variable "webdav_port" {
  description = "webdav port (use 0 to disable)"
  type        = number
  default     = 0
}

variable "rack" {
  description = "Prefer to write to volumes in this rack"
  type        = string
  default = ""
}

variable "collection" {
  description = "All data will be stored in this collection"
  type        = string
  default     = "default"
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  // gRPC offset if the port is not set explicitly
  grpc_offset = 10000
  // Service
  service = "filer"
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "seaweedfs-filer-${ name }" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  ///////////////////////////////////////////////////////////////////////////////

  group "filer" {
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

      // webdav port is only exposed if enabled
      dynamic "port" {
        for_each = var.webdav_port > 0 ? [1] : []
        labels   = ["webdav"]
        content {
          static = var.webdav_port
          to     = var.webdav_port
        }
      }      
    }

    service {
      tags     = ["http", var.service_name, local.service]
      name     = format("%s-%s-http", local.service, var.service_name)
      port     = "http"
      provider = var.service_provider
    }

    service {
      tags     = ["grpc", var.service_name, local.service]
      name     = format("%s-%s-grpc",  local.service,var.service_name)
      port     = "grpc"
      provider = var.service_provider
    }

    dynamic "service" {
      for_each = var.metrics_port > 0 ? [1] : []
      content {
        tags     = ["metrics", var.service_name,  local.service]
        name     = format("%s-%s-metrics",  local.service,var.service_name)
        port     = "metrics"
        provider = var.service_provider
      }
    }

    dynamic "service" {
      for_each = var.webdav_port > 0 ? [1] : []
      content {
        tags     = ["webdav", var.service_name,  local.service]
        name     = format("%s-%s-webdav",  local.service,var.service_name)
        port     = "webdav"
        provider = var.service_provider
      }
    }    

    task "filer" {    
      driver = "docker"      
      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        dns_servers = var.service_dns
        args = compact([
          "-logtostderr",
          "filer",
          "-ip=$${node.unique.name}",
          "-ip.bind=0.0.0.0",
          "-port=$${NOMAD_PORT_http}",
          "-port.grpc=$${NOMAD_PORT_grpc}",
          format("-master=%s", join(",", var.masters)),
          var.metrics_port == 0 ? "" : "-metricsPort=$${NOMAD_PORT_metrics}",
          "-defaultStoreDir=/data",
          var.rack == "" ? "" : format("-rack=%s", var.rack),
          var.collection == "" ? "" : format("-collection=%s", var.collection),
          var.webdav_port == 0 ? "" : "-webdav",
          var.webdav_port == 0 ? "" : "-webdav.port=$${NOMAD_PORT_webdav}",
        ])
        volumes = compact([
          var.data == "" ? "" : format("%s:/data", var.data),
        ])
        ports = compact([
          "http",
          "grpc",
          var.metrics_port > 0 ? "metrics" : "",
          var.webdav_port > 0 ? "webdav" : "",
        ])
      } // config
    } // task "filer"
  }   // group "filer"

  ///////////////////////////////////////////////////////////////////////////////

} // job "seaweedfs"
