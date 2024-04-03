
resource "nomad_job" "openldap" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/openldap-admin.hcl")

  hcl2 {
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      hosts              = jsonencode(var.hosts)
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      service_provider   = var.service_provider
      service_name       = var.service_name
      service_dns        = jsonencode(var.service_dns)
      service_type       = var.service_type

      port           = var.port
      url            = var.url
      basedn         = var.basedn
      admin_user     = var.admin_user
      admin_password = var.admin_password
      organization   = var.organization
      domain         = var.domain
      debug          = var.debug
    }
  }
}
