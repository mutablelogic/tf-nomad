
locals {
    docker_image = "bobblybook/metabase:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
