
locals {
    docker_image = "semaphoreui/semaphore:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
