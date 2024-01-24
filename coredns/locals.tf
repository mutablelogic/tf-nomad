
locals {
    docker_image = "coredns/coredns:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
