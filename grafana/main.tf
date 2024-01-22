
resource "nomad_job" "grafana" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/grafana.hcl")

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
      admin_email        = var.admin_email
      anonymous_enabled  = var.anonymous
      anonymous_org      = ""
      anonymous_role     = "Viewer"
    }
  }
}
