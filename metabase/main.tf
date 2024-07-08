
resource "nomad_job" "metabase" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/metabase.hcl")

  hcl2 {
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      service_dns        = jsonencode(var.service_dns)
      service_name       = var.service_name

      // Parameters
      hosts       = jsonencode(var.hosts)
      port        = var.port
      data        = var.data
      url         = var.url
      db          = jsonencode(var.db)
      db_password = var.db_password
    }
  }
}
