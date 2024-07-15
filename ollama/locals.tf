
locals {
    docker_image = "ollama/ollama:${var.docker_tag}"
    docker_image_webui = var.docker_tag_webui == "" ? "" : "ghcr.io/open-webui/open-webui:${var.docker_tag_webui}"
    docker_always_pull = var.docker_tag == "latest" ? true : false
}
