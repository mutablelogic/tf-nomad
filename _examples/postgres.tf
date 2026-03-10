
module "postgres" {
  source = "github.com/mutablelogic/tf-nomad//postgres"

  enabled   = true // If false, no-op
  dc        = var.dc
  namespace = var.namespace

  service_dns  = ["192.168.86.11", "192.168.86.12", "192.168.86.13"]
  networks     = ["lan", "vpn"] // Bind ports to specific host networks (optional)
  service_name = "postgresql"   // Service name (optional, default: postgresql)

  docker_tag = "17-bookworm" // Docker image tag (optional)

  primary  = "cm2"                 // Primary server node
  replicas = ["cm3", "cm5"]        // Read-only replica server nodes (optional)
  port     = 5432                  // Port to expose (optional)
  database = "postgres"            // Default database name (optional)
  data     = "/var/lib/postgresql" // Persistence directory (optional)

  root_user     = local.POSTGRESQL_ROOT_USER     // Root user (optional, default: postgres)
  root_password = local.POSTGRESQL_ROOT_PASSWORD // Root password (required)

  replication_user     = local.POSTGRESQL_REPLICATION_USER     // Replication user (optional)
  replication_password = local.POSTGRESQL_REPLICATION_PASSWORD // Replication password (optional)
  replication_network  = "lan"                                 // Network for replication traffic (optional)

  primary_memory = 2048 // Memory in MB for primary task (optional)
  replica_memory = 512  // Memory in MB for each replica task (optional)

  ssl_cert = "/etc/ssl/certs/postgres.crt"   // Host path to SSL certificate (optional)
  ssl_key  = "/etc/ssl/private/postgres.key" // Host path to SSL private key (optional)
  ssl_ca   = "/etc/ssl/certs/ca.crt"         // Host path to SSL CA certificate (optional)
}

output "postgres_primary_services" {
  value = module.postgres.primary_services
}

output "postgres_replica_services" {
  value = module.postgres.replica_services
}
