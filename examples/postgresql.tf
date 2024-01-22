
module "postgresql" {
  source = "github.com/mutablelogic/tf-nomad/openldap"

  // Required parameters
  dc            = local.datacenter               // Nomad datacenter for the cluster
  namespace     = local.namespace                // Nomad namespace for the cluster
  hosts         = ["cm2"]                        // Host constraint for the job
  root_password = local.POSTGRESQL_ROOT_PASSWORD // Password for the 'root' user

  // Optional parameters
  enabled  = true      // If false, no-op
  port     = 5432      // Port to expose
  database = "default" // Default database name
}
