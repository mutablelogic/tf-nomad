
resource "nomad_job" "github-action-runner" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/github-action-runner.hcl")

  hcl2 {
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      hosts              = jsonencode(var.hosts)
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      service_dns        = jsonencode(var.service_dns)
      service_type       = var.service_type

      // Runner parameters
      access_token = var.access_token
      organization = var.organization
      name         = var.name
      group        = var.group
      labels       = jsonencode(var.labels)
    }
  }
}
