
module "coredns" {
  source = "github.com/mutablelogic/tf-nomad//coredns"

  // Required parameters
  dc          = local.datacenter  // Nomad datacenter for the cluster
  namespace   = local.namespace   // Nomad namespace for the cluster
  nomad_addr  = local.nomad_addr  // Address of the Nomad server
  nomad_token = local.nomad_token // Token for the Nomad server

  // Optional parameters
  service_type = "system"         // System or service
  service_dns  = ["dns1", "dns2"] // Upstream DNS
  enabled      = true             // Enable job
  debug        = true             // Switch on debugging log output
  hosts        = ["server1"]      // Host constraint for the job
  port         = 53               // Port to expose for plaintext connections
  cache_ttl    = 30               // Cache TTL in seconds
  dns_zone     = "nomad"          // DNS zone to serve
}
