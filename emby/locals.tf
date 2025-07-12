
locals {
    docker_image = "linuxserver/emby:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "4.9.1-beta" ? true : false
}
