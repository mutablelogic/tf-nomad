
locals {
  docker_image       = "lscr.io/linuxserver/swag:${var.docker_tag}"
  docker_always_pull = var.docker_tag == "latest" ? true : false
  http_port_env      = length(var.networks) > 0 ? format("NOMAD_PORT_HTTP_%s", upper(replace(var.networks[0], "-", "_"))) : "NOMAD_PORT_http"
  https_port_env     = length(var.networks) > 0 ? format("NOMAD_PORT_HTTPS_%s", upper(replace(var.networks[0], "-", "_"))) : "NOMAD_PORT_https"
}
