
resource "nomad_job" "semaphore" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/semaphore.hcl")

  hcl2 {
    allow_fs = true
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      service_provider   = var.service_provider
      service_name       = var.service_name
      service_dns        = jsonencode(var.service_dns)
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      hosts              = jsonencode(var.hosts)
      port               = var.port
      admin_user         = var.admin_user
      admin_password     = var.admin_password
      db_type            = var.db.type
      db_host            = var.db.host
      db_port            = var.db.port
      db_name            = var.db.name
      db_user            = var.db.user
      db_password        = var.db_password
      ldap_host          = var.ldap.host
      ldap_port          = var.ldap.port
      ldap_tls           = var.ldap.tls
      ldap_dn_bind       = var.ldap.dn_bind
      ldap_password      = var.ldap_password
      ldap_dn_search     = var.ldap.dn_search
      ldap_filter_search = var.ldap.filter_search
    }
  }
}
