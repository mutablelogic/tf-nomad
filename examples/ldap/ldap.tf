
// Example LDAP server, using the bitnami/openldap docker image
module "ldap" {
  source = "github.com/mutablelogic/tf-nomad/ldap"

  // Required parameters
  dc             = "datacenter"              // Nomad datacenter for the cluster
  hosts          = ["server1", "server2"]    // Host constraint for the job
  basedn         = "dc=mutablelogic,dc=com"  // Distinquished name for the LDAP server
  admin_password = local.LDAP_ADMIN_PASSWORD // Password for the LDAP 'admin' user
  data           = "/var/lib/ldap"           // Data persistence directory

  // Optional parameters
  enabled    = true      // If false, no-op
  namespace  = "default" // Nomad namespace for the nomad job
  docker_tag = "latest"  // Pull the latest version of the docker image every job restart
  port       = 1389      // plaintext port to expose
}
