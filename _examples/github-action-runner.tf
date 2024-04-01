
module "github-action-runner" {
  source = "github.com/mutablelogic/tf-nomad//github-action-runner"

  // Required parameters
  dc          = local.datacenter  // Nomad datacenter for the cluster
  namespace   = local.namespace   // Nomad namespace for the cluster

  // Runner parameters
  organization = local.GITHUB_ORGANIZATION       // GitHub organization
  access_token = local.GITHUB_TOKEN              // GitHub access token
  group        = local.datacenter                // Group for the runner (optional)
  labels       = [local.namespace, local.region] // Labels for the runner (optional)

  // Optional parameters
  service_type = "service"             // System or service
  enabled      = true                  // Enable job
  hosts        = ["cm1", "cm2", "cm3"] // Host constraint for the job

  // Data persistence directory
  data        = "/var/lib/github-action-runner"     
}
