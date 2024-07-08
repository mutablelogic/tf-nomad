
module "metabase" {
  source      = "github.com/mutablelogic/tf-nomad//metabase"
  enabled     = true // If false, no-op
  dc          = var.dc
  namespace   = var.namespace
  docker_tag  = "latest" // Pull the latest version of the docker image every job restart
  service_dns = ["192.168.86.11", "192.168.86.12", "192.168.86.13"]

  data  = "/var/lib/metabase"
  hosts = ["server1", "server2"] // Host constraint for the job
  port  = 3001                   // Port to expose
  url   = "https://metabase.dashboard.com/" // How to access

  db = {
    type = "postgres"
    host = "postgresql.default.nomad."
    port = 5432
    name = "metabase"
    user = "metabase"
  }
  db_password = var.db_password
}
