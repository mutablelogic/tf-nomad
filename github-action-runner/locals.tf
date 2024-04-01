
locals {
    docker_image = "ghcr.io/actions/actions-runner:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
