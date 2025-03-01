
resource "nomad_job" "llm" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/llm.hcl")

  hcl2 {
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      service_dns        = jsonencode(var.service_dns)
      hosts              = jsonencode(var.hosts)
      debug              = var.debug
      model              = var.model
      system             = var.system
      timeout            = var.timeout
      keys               = jsonencode(var.keys)
    }
  }
}
