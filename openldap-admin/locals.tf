
locals {
    docker_image = "wheelybird/ldap-user-manager:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
