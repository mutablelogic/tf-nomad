
// Example telegraf time-series metrics collector
module "telegraf" {
  source = "github.com/mutablelogic/tf-nomad//telegraf"

  // Required parameters
  dc        = local.datacenter // Nomad datacenter for the cluster
  namespace = local.namespace  // Nomad namespace for the cluster
  hosts     = ["cm2"]          // Host constraint for the job

  // Optional parameters
  enabled = true

  // Configuration for telegraf output plugins
  outputs = {
    influxdb_v2 = {
      urls         = jsonencode(["http://cm2:9999"])
      token        = jsonencode(local.INFLUXDB_ADMIN_TOKEN)
      organization = jsonencode("mutablelogic")
      bucket       = jsonencode("default")
    }
  }

  // Configuration for telegraf input plugins
  inputs = {
    internal = {
      collect_memstats = jsonencode(true)
    }
    cpu = {
      percpu           = jsonencode(true)
      totalcpu         = jsonencode(true)
      collect_cpu_time = jsonencode(false)
      report_active    = jsonencode(false)
    }
    disk = {
      ignore_fs = jsonencode(["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"])
    }
    diskio    = {}
    kernel    = {}
    mem       = {}
    processes = {}
    swap      = {}
    system    = {}
    net = {
      interfaces = jsonencode(["eth0"])
    }
    temp = {}
    ping = {
      urls  = jsonencode(["8.8.8.8"])
      count = jsonencode(10)
    }
  }
}
