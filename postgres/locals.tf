
locals {
  docker_image       = "ghcr.io/mutablelogic/docker-postgres:${var.docker_tag}"
  docker_always_pull = true

  primary_services = var.enabled ? (
    length(var.networks) > 0 ? [
      for n in var.networks : "${var.service_name}-primary-${n}.${var.namespace}.nomad."
    ] : ["${var.service_name}-primary.${var.namespace}.nomad."]
  ) : []

  replica_services = var.enabled && length(var.replicas) > 0 ? (
    length(var.networks) > 0 ? [
      for n in var.networks : "${var.service_name}-replica-${n}.${var.namespace}.nomad."
    ] : ["${var.service_name}-replica.${var.namespace}.nomad."]
  ) : []
}
