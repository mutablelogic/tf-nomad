
resource "nomad_job" "prometheus" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/prometheus.hcl")

  hcl2 {
    allow_fs = true
    vars = {
    dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      hosts              = jsonencode(var.hosts)
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      service_provider   = var.service_provider
      service_dns        = jsonencode(var.service_dns)

      hosts              = jsonencode(var.hosts)
      port               = var.port
      data               = var.data
      configs            = jsonencode({
        "prometheus.yml" = chomp(file("${path.module}/config/prometheus.yml"))
      })
      flags             = jsonencode({
        "storage.tsdb.retention.time" = "1y"
      })
      targets           = jsonencode(var.targets)
    }
  }
}
