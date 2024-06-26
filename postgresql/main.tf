
resource "nomad_job" "postgresql" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/postgresql.hcl")

  hcl2 {
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      service_provider   = var.service_provider
      service_name       = var.service_name
      service_dns        = jsonencode(var.service_dns)
      service_type       = var.service_type

      hosts         = jsonencode(var.hosts)
      port          = var.port
      data          = var.data
      root_user     = var.root_user
      root_password = var.root_password
      database      = var.database
    }
  }
}
