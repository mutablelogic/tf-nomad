
// Example grafana dashboard example
module "grafana" {
  source = "github.com/mutablelogic/tf-nomad//grafana"

  // Required parameters  
  dc             = local.datacenter             // Nomad datacenter for the cluster
  namespace      = local.namespace              // Nomad namespace for the cluster
  enabled        = true                         // If false, no-op
  admin_email    = "admin@mutablelogic"         // Email address for the admin user
  admin_password = local.GRAFANA_ADMIN_PASSWORD // Password for the admin user

  // Optional parameters
  hosts      = ["server1"] // Host constraint for the job. If not specified, the job will be deployed to one node
  docker_tag = "latest"    // Pull the latest version of the docker image every job restart
  port       = 3000        // Port to expose
  anonymous  = false       // When true, allow anonymous access as a viewer

  // Data persistence directory. If not set, then data is not persisted. When persistence is enabled,
  // set user/group to 472 for the container to have write access to the data directory
  data = "/var/lib/grafana"
}
