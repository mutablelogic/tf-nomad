
locals {
  docker_image       = "ghcr.io/mutablelogic/docker-postgres:${var.docker_tag}"
  docker_always_pull = true
}
