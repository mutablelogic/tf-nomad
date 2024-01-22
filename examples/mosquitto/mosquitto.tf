
// Example MQTT broker, using the eclipse-mosquitto docker image
module "mqtt" {
  source = "github.com/mutablelogic/tf-nomad/mosquitto"

  // Required parameters
  dc    = "datacenter"           // Nomad datacenter for the cluster
  hosts = ["server1", "server2"] // Host constraint for the job

  // Optional parameters
  enabled    = true            // If false, no-op
  namespace  = "default"       // Nomad namespace for the cluster
  docker_tag = "latest"        // Pull the latest version of the docker image every job restart
  port       = 1883            // Port to expose
  data       = "/var/lib/mqtt" // Data persistence directory
}
