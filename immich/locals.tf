
locals {
    docker_image = "ghcr.io/immich-app/immich-server:${var.docker_tag}"
    docker_ml_tag = var.docker_ml_runtime == "nvidia" ? "-cuda" : ""
    docker_ml_image = "ghcr.io/immich-app/immich-machine-learning:${var.docker_tag}${local.docker_ml_tag}"
    docker_redis_image = "redis:7"
    docker_always_pull = var.docker_tag == "release" ? true : false
}
