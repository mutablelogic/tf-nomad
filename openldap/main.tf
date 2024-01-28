
resource "nomad_job" "openldap" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/openldap.hcl")

  hcl2 {
    allow_fs = true
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
      data           = var.data
      admin_password = var.admin_password
      basedn         = var.basedn
      organization   = var.organization

      # LDIF templates which are only applied when the data directory is empty (first run)
      ldif = jsonencode({
        "root" = file("${path.module}/ldif/root.ldif")
      })
      schema = jsonencode({
        "memberOf"   = file("${path.module}/schema/memberOf.ldif"),
        "rfc2307bis" = file("${path.module}/schema/rfc2307bis.ldif")
      })
    }
  }
}
