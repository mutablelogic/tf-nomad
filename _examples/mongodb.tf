
// Example mongodb document database
module "mongodb" {
  source = "github.com/mutablelogic/tf-nomad//mongodb"

  // Required parameters
  dc             = "datacenter"                 // Nomad datacenter for the cluster
  hosts          = ["server1", "server2"]       // Host constraint for the job
  admin_password = local.MONGODB_ADMIN_PASSWORD // Password for the 'admin' user

  // Optional parameters
  enabled         = true               // If false, no-op
  namespace       = "default"          // Nomad namespace for the cluster
  docker_tag      = "latest"           // Pull the latest version of the docker image every job restart
  port            = 27017              // Port to expose
  data            = "/var/lib/mongodb" // Data persistence directory
  replicaset_name = "rs0"              // Replica set name
}
