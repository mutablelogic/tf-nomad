
locals {
    docker_image = "osixia/openldap:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
