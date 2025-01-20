
module "postgres" {
  source = "github.com/mutablelogic/tf-nomad//postgres"

  enabled    = true // If false, no-op
  dc         = var.dc
  namespace  = var.namespace
  service_dns = ["192.168.86.11", "192.168.86.12", "192.168.86.13"]

  root_user            = local.POSTGRESQL_ROOT_USER            // User for the 'root' user (default: postgres)
  root_password        = local.POSTGRESQL_ROOT_PASSWORD        // Password for the 'root' user
  replication_user     = local.POSTGRESQL_REPLICATION_USER     // User for the 'replication' user (default: replicator)
  replication_password = local.POSTGRESQL_REPLICATION_PASSWORD // Password for the 'replication' user

  primary = "cm2"                  // Primary server node
  replicas = [ "cm3", "cm5" ]      // One or more read-only replica server nodes
  port     = 5432                  // Port to expose (optional)
  database = "postgres"            // Default database name (optional)
  data     = "/var/lib/postgresql" // Persistence directory
}
