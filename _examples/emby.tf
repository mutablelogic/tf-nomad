
module "emby" {
  source = "github.com/mutablelogic/tf-nomad//emby"

  // Required parameters
  dc          = var.dc
  namespace   = var.namespace
  service_dns = ["dns1", "dns2"]

  // Optional parameters
  enabled    = true
  host       = "mediahost"
  port       = 8096
  data       = "/var/lib/emby"
  media      = ["/home/media", "/home/media2"]
}
