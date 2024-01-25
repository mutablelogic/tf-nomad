
// Example nginx reverse proxy module
module "nginx" {
  source = "github.com/mutablelogic/tf-nomad//nginx"

  // Required parameters
  dc = "datacenter" // Nomad datacenter for the cluster

  // Optional parameters
  enabled    = true                   // If false, no-op
  namespace  = "default"              // Nomad namespace for the cluster
  docker_tag = "latest"               // Pull the latest version of the docker image every job restart
  hosts      = ["server1", "server2"] // Host constraint for the job, it not specified, deploys on a single host
  ports = {                           // Ports to expose
    http  = 80
    https = 443
  }
  servers = [ // List of servers to configure
    {
      name = "default"
      data = file("nginx-default.conf")
    }
  ]
}
