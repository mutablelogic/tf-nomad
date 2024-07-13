
resource "nomad_job" "emby" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/emby.hcl")

  hcl2 {
    allow_fs = true
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      service_dns        = jsonencode(var.service_dns)
      service_name       = var.service_name
      host               = var.host
      port               = var.port
      data               = var.data
      media              = jsonencode(var.media)
      devices            = jsonencode(var.devices)
      timezone           = var.timezone
    }
  }
}
