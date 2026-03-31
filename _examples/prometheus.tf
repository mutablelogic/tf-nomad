// Example Prometheus deployment with native OTLP ingestion enabled
module "prometheus" {
  source = "github.com/mutablelogic/tf-nomad//prometheus"

  // Required parameters
  dc        = local.datacenter // Nomad datacenter for the cluster
  namespace = local.namespace  // Nomad namespace for the cluster
  enabled   = true             // If false, no-op

  // Optional parameters
  hosts                = ["server1"] // Host constraint for the job. If not specified, the job will be deployed to one node
  docker_tag           = "latest"    // Pull the latest version of the docker image every job restart
  port                 = 9090         // Port to expose
  data                 = "/var/lib/prometheus"
  enable_otlp_receiver = true         // Accept OpenTelemetry metrics over OTLP HTTP on /api/v1/otlp/v1/metrics

  targets = {
    prometheus = {
      interval = "1m"
      path     = "/metrics"
      scheme   = "http"
      targets  = ["localhost:9090"]
    }
  }
}