
resource "nomad_job" "nginx" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/nginx.hcl")

  hcl2 {
    allow_fs = true
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      hosts              = jsonencode(var.hosts)
      ports              = jsonencode(var.ports)
      config             = chomp(file("${path.module}/config/nginx.conf"))
      mimetypes          = chomp(file("${path.module}/config/mimetypes.conf"))
      servers            = jsonencode(var.servers)
    }
  }
}
