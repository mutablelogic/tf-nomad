
locals {
    docker_image = "grafana/grafana:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
