resource "nomad_job" "seaweedfs" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/../../../nomad/seaweedfs.hcl")

  hcl2 {
    allow_fs = true
    vars = {
      dc        = jsonencode(var.dc)
      namespace = var.namespace

      // IP addresses for all the masters in the cluster
      masters   = jsonencode([for k, v in var.masters : v])
    }
  }
}
