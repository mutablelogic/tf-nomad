
locals {
    docker_image = "timescale/timescaledb-ha:${var.docker_tag}"
    docker_always_pull = var.docker_tag == "latest-pg16" ? true : false
}
