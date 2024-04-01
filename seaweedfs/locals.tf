
locals {
    docker_image = "chrislusf/seaweedfs:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
