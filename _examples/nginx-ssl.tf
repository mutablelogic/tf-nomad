
// Example nginx reverse proxy module, with in-build SSL support
module "nginx-ssl" {
  source = "github.com/mutablelogic/tf-nomad//nginx-ssl"

  // Service parameters
  dc = "datacenter" // Nomad datacenter for the cluster
  enabled    = true                   // If false, no-op
  namespace  = "default"              // Nomad namespace for the cluster
  docker_tag = "latest"               // Pull the latest version of the docker image every job restart
  hosts      = ["server1", "server2"] // Host constraint for the job, it not specified, deploys on a single host
  ports = {                           // Ports to expose
    http  = 80
    https = 443
  }

  // Job parameters
  zone               = "domain.com"
  email              = "djt@domain.com"
  dns_validation     = "cloudflare" // Use http, cloudflare or duckdns
  cloudflare_api_key = local.CLOUDFARE_TOKEN // Cloudflare API key
  staging            = false // Set to true for testing

  servers = { // List of servers to configure
    "default.conf" = file("nginx-ssl.conf")
  }
}
