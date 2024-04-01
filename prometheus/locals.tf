
locals {
    docker_image = "prom/prometheus:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
