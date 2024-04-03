
// Once the job is running, you should proceed to set-up http://<service_dns>:5000/setup
module "openldap-admin" {
  source = "github.com/mutablelogic/tf-nomad//openldap-admin"

  // Required parameters
  dc        = local.datacenter // Nomad datacenter for the cluster
  namespace = local.namespace  // Nomad namespace for the cluster
  hosts     = ["cm1"]          // Host constraint for the job

  // Optional parameters
  enabled     = true             // If false, no-op
  port        = 5000             // Port to expose
  service_dns = ["dns1", "dns2"] // Service discovery DNS

  // LDAP parameters
  url            = "ldap://openldap-ldap.default.nomad:389/"
  basedn         = format("dc=%s,dc=com",local.organization)
  admin_password = local.LDAP_ADMIN_PASSWORD
  organization   = local.organization
  domain         = local.domain
  debug          = false
}
