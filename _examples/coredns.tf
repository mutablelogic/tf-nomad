
module "coredns" {
  source = "github.com/mutablelogic/tf-nomad//coredns"

  // Required parameters
  dc        = local.datacenter // Nomad datacenter for the cluster
  namespace = local.namespace  // Nomad namespace for the cluster

  // Optional parameters
  enabled = true
  hosts   = ["cm3"] // Host constraint for the job
  port    = 53      // Port to expose for plaintext connections
}
