
locals {
    docker_image = "ghcr.io/mutablelogic/go-service:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
