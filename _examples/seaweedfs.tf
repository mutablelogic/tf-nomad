
// Example Cluster filesystem using seaweedfs, with one master, two volumes and one filer
module "seaweedfs" {
  source     = "github.com/mutablelogic/tf-nomad//seaweedfs"
  enabled    = true // If false, no-op
  dc         = local.datacenter
  namespace  = local.namespace
  docker_tag = "latest" // Pull the latest version of the docker image every job restart

  replication = "000" // https://github.com/seaweedfs/seaweedfs/wiki/Replication#the-meaning-of-replication-type
  metrics     = false // If true, allow metrics collection by prometheus

  masters = {
    "192.168.86.12" : {
      "name" : "cm2",               // Unique name identifying the master server
      "data" : "/var/lib/seaweedfs" // Persistent data
    }
  }

  volumes = {
    "192.168.86.12" : {
      "name" : "cm2",              // Unique name identifying the volume server
      "data" : ["/mnt/clusterfs"], // Location of the volume data
      "rack" : "rack1",            // Rack name where server is located
    }
    "192.168.86.13" : {
      "name" : "cm3",              // Unique name identifying the volume server
      "data" : ["/mnt/clusterfs"], // Location of the volume data
      "rack" : "rack1",            // Rack name where server is located
    }
  }

  filers = {
    "192.168.86.13" : {
      "name"       : "cm3",               // Unique name identifying the filer server
      "data"       : "/var/lib/seaweedfs" // Persistent data
      "collection" : "drobo",             // Store data in this collection
      "rack"       : "rack1",             // Preferred rack to write data in
      "s3"         : true,                // Enable S3
      "webdav"     : true,                // Enable WebDAV
    }
  }
}
