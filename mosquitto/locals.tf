
locals {
    docker_image = "eclipse-mosquitto:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
