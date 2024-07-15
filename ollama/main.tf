
resource "nomad_job" "ollama" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/ollama.hcl")

  hcl2 {
    allow_fs = true
    vars = {
      dc                 = jsonencode(var.dc)
      namespace          = var.namespace
      docker_image       = local.docker_image
      docker_image_webui = local.docker_image_webui
      docker_always_pull = jsonencode(local.docker_always_pull)
      service_provider   = var.service_provider
      service_dns        = jsonencode(var.service_dns)
      service_name       = var.service_name
      hosts              = jsonencode(var.hosts)
      hosts_webui        = jsonencode(var.hosts_webui)
      port               = var.port
      port_webui         = var.port_webui
      data               = var.data
      devices            = jsonencode(var.devices)
      openai_api_key     = var.openai_api_key
    }
  }
}
