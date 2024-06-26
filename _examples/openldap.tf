
// Example LDAP server
module "openldap" {
  source = "github.com/mutablelogic/tf-nomad//openldap"

  // Required parameters
  dc              = "datacenter"              // Nomad datacenter for the cluster
  hosts           = ["server1", "server2"]    // Host constraint for the job
  organization    = "My Organization"         // Distinquished name for the LDAP server
  domain          = "example.com"             // Domain for the LDAP server
  admin_password  = local.LDAP_ADMIN_PASSWORD // Password for the LDAP 'admin' user
  config_password = local.LDAP_ADMIN_PASSWORD // Password for the LDAP 'config' user

  // Optional parameters
  enabled           = true                                           // If false, no-op
  namespace         = "default"                                      // Nomad namespace for the nomad job
  docker_tag        = "latest"                                       // Pull the latest version of the docker image every job restart
  port              = 389                                            // plaintext port to expose
  replication_hosts = ["ldap://server1:389/", "ldap://server2:389/"] // LDAP urls for replication
  data              = "/var/lib/ldap"                                // Directory for data persistence
}

// Example LDAP admin
module "openldap-admin" {
  source =  "github.com/mutablelogic/tf-nomad//openldap-admin"

  // Required parameters
  dc             = var.dc
  hosts           = ["server1", "server2"]    // Host constraint for the job
  organization    = "My Organization"         // Distinquished name for the LDAP server
  domain          = "example.com"             // Domain for the LDAP server
  admin_password  = local.LDAP_ADMIN_PASSWORD // Password for the LDAP 'admin' user

  // Other parameters
  enabled        = true
  namespace      = var.namespace
  docker_tag        = "latest"                                       // Pull the latest version of the docker image every job restart
  port              = 5000                                           // plaintext port to expose

  // LDAP details
  service_dns    = ["192.168.86.11", "192.168.86.12"]
  url            = "ldap://openldap-ldap.default.nomad/"
  basedn         = "dc=mutablelogic,dc=com"
}
