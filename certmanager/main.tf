
resource "nomad_job" "certmanager" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/certmanager.hcl")

  hcl2 {
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      service_provider   = var.service_provider
      service_name       = var.service_name
      service_dns        = jsonencode(var.service_dns)
      hosts              = jsonencode(var.hosts)
      port               = var.port
      debug              = var.debug
      database           = jsonencode(var.database)
      database_password  = var.database_password
      renew_before_days  = var.renew_before_days
      renew_cert_days    = var.renew_cert_days
      renew_ca_days      = var.renew_ca_days
    }
  }
}
