
module "postgresql" {
  source = "github.com/mutablelogic/tf-nomad//postgresql"

  // Required parameters
  dc            = local.datacenter               // Nomad datacenter for the cluster
  namespace     = local.namespace                // Nomad namespace for the cluster
  hosts         = ["server1"]                    // Host constraint for the job
  root_user     = local.POSTGRESQL_ROOT_USER     // User for the 'root' user (default: postgres)
  root_password = local.POSTGRESQL_ROOT_PASSWORD // Password for the 'root' user

  // Optional parameters
  enabled  = true                  // If false, no-op
  port     = 5432                  // Port to expose (optional)
  database = "default"             // Default database name
  data     = "/var/lib/postgresql" // Persistence directory
}
