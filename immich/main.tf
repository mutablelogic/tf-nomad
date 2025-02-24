
resource "nomad_job" "immich" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/immich.hcl")

  hcl2 {
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      hosts              = jsonencode(var.hosts)
      docker_image       = local.docker_image
      docker_redis_image = local.docker_redis_image
      docker_ml_image    = local.docker_ml_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      service_provider   = var.service_provider
      service_name       = var.service_name
      service_dns        = jsonencode(var.service_dns)
      port               = var.port
      data               = var.data
      media              = jsonencode(var.media)
      database           = jsonencode(var.database)
    }
  }
}
