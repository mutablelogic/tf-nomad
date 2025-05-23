
module "immich" {
  source = "github.com/mutablelogic/tf-nomad//immich"

  // Required parameters  
  dc        = local.datacenter // Nomad datacenter for the cluster
  namespace = local.namespace  // Nomad namespace for the cluster
  enabled   = true             // If false, no-op
  database = {
    host     = "postgres-primary.default.nomad."
    port     = 5432
    name     = "immich"
    user     = "immich"
    password = local.IMMICH_ADMIN_PASSWORD
    ssl_mode = "disable"
  }

  // Optional parameters
  service_dns = var.service_dns // DNS resolver
  hosts       = ["server1"]     // Host constraint for the job. If not specified, the job will be deployed to one node
  docker_tag  = "release"       // Pull the release version of the docker image every job restart
  port        = 2283            // Port to expose

  // Media locations
  data  = "/var/lib/immich" // Data persistence directory - contains the main library
  media = []                // Other external libraries, which are mapped to /media, /media1, /media2, etc. in the container

  // Machine learning parameters
  mlhosts           = ["nvidia1"] // Host constaint for machine learning server
  docker_ml_runtime = "nvidia"    // Required for NVIDIA GPU
}

/*
When you create a new instance, you need a fresh database in your PostgreSQL server.
You can create a new database with the following commands, replacing the password
for your 'immich' user:

CREATE ROLE immich WITH LOGIN PASSWORD 'XXXXXX';
CREATE DATABASE immich WITH OWNER 'immich';

-- Run the following commands in the 'immich' database
CREATE EXTENSION IF NOT EXISTS vector CASCADE;
CREATE EXTENSION IF NOT EXISTS cube CASCADE;
CREATE EXTENSION IF NOT EXISTS earthdistance CASCADE;
*/


