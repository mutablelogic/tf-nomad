
// Example grafana dashboard example
module "grafana" {
  source = "github.com/mutablelogic/tf-nomad/grafana"

  // Required parameters  
  dc             = local.datacenter             // Nomad datacenter for the cluster
  namespace      = local.namespace              // Nomad namespace for the cluster
  hosts          = ["cm2"]                      // Host constraint for the job
  admin_password = local.GRAFANA_ADMIN_PASSWORD // Password for the admin user

  // Optional parameters
  enabled     = true                 // If false, no-op
  docker_tag  = "latest"             // Pull the latest version of the docker image every job restart
  port        = 3000                 // Port to expose
  data        = "/var/lib/influxdb"  // Data persistence directory
  admin_email = "admin@mutablelogic" // Email address for the admin user
  anonymous   = false                // When true, allow anonymous access as a viewer
}
