
resource "nomad_job" "coredns" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/coredns.hcl")

  hcl2 {
    allow_fs = true
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
      corefile           = file("${path.module}/config/Corefile")
      nomad_addr         = var.nomad_addr
      nomad_token        = var.nomad_token
      cache_ttl          = var.cache_ttl
      dns_zone           = var.dns_zone
    }
  }
}
