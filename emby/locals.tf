
locals {
    docker_image = "linuxserver/emby:${var.docker_tag}"
    docker_always_pull = (var.docker_tag == "latest" || var.docker_tag == "beta") ? true : false
}
