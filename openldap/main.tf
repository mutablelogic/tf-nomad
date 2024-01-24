
resource "nomad_job" "ldap" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/openldap.hcl")

  hcl2 {
    allow_fs = true
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      hosts              = jsonencode(var.hosts)
      port               = var.port
      data               = var.data
      admin_password     = var.admin_password
      basedn             = var.basedn
      organization       = var.organization
      ldif = jsonencode({
        "root" = file("${path.module}/ldif/root.ldif")
      })
      schema = jsonencode({})
    }
  }
}
