
// Example Cluster filesystem using seaweedfs, with one master, two volumes and three filers
module "clusterfs" {
  source      = "github.com/mutablelogic/tf-nomad/seaweedfs"
  enabled     = true         // If false, no-op
  dc          = "datacenter" // Nomad datacenter for the cluster
  namespace   = "clusterfs"  // Nomad namespace for the cluster
  docker_tag  = "latest"     // Pull the latest version of the docker image every job restart
  metrics     = true         // Provide metrics ports for prometheus pulls
  webdav      = false        // Enable webdav service on filers
  s3          = false        // Enable s3 service on filers
  replication = "000"        // https://github.com/seaweedfs/seaweedfs/wiki/Replication#the-meaning-of-replication-type
  masters = [
    {
      ip = "192.168.86.11"
    }
  ]
  volumes = [
    {
      ip    = "192.168.86.12",
      disks = "/mnt/clusterfs", // comma-separated list of mounted disks for storage
      rack  = "rack1",          // Rack location for this server
      max   = 0                 // Maximum number of volumes to create on this server, or 0 for auto
    }, {
      ip    = "192.168.86.13",
      disks = "/mnt/clusterfs", // comma-separated list of mounted disks for storage
      rack  = "rack1",          // Rack location for this server
      max   = 0                 // Maximum number of volumes to create on this server, or 0 for auto
    }
  ]
  filers = [
    {
      ip = "192.168.86.11"
    }, {
      ip = "192.168.86.12"
    }, {
      ip = "192.168.86.13"
    }
  ]
}
