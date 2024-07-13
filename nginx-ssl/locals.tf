
locals {
    docker_image = "lscr.io/linuxserver/swag:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
