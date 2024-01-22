resource "nomad_job" "mosquitto" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/mosquitto.hcl")

  hcl2 {
    allow_fs = true
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      hosts              = jsonencode(var.hosts)
      port               = jsonencode(var.port)
      data               = var.data
    }
  }
}
