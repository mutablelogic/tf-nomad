
// Example InfluxDB time-series database
module "influxdb" {
  source = "github.com/mutablelogic/tf-nomad/influxdb"

  // Required parameters
  dc             = "datacenter"                  // Nomad datacenter for the cluster
  hosts          = ["server1", "server2"]        // Host constraint for the job
  admin_password = local.INFLUXDB_ADMIN_PASSWORD // Password for the 'admin' user
  organization   = "mutablelogic"                // Organization name
  data           = "/var/lib/influxdb"           // Data persistence directory

  // Optional parameters
  enabled    = true      // If false, no-op
  namespace  = "default" // Nomad namespace for the cluster
  docker_tag = "latest"  // Pull the latest version of the docker image every job restart
  port       = 1883      // Port to expose
}
