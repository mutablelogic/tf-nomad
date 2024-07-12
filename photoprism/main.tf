
resource "nomad_job" "photoprism" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/photoprism.hcl")

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
      mariadb_host       = var.host
      mariadb_data       = var.mariadb_data
      mariadb_password   = var.admin_password
      mariadb_root_password = var.admin_password
      admin_user         = var.admin_user
      admin_password     = var.admin_password
    }
  }
}
