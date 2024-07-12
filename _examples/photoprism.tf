
module "photoprism" {
  source = "github.com/mutablelogic/tf-nomad//photoprism"

  // Service parameters
  dc          = var.dc
  namespace   = var.namespace
  service_dns = ["192.168.86.X", "192.168.86.Y", "192.168.86.Z"]

  // Photoprism parameters
  enabled = true       // If false, no-op
  host    = "hostname" // Host to run photoprism and mariadb on
  port    = 2342
  url     = "https://photos.com/"

  // Data paths
  data           = "/var/lib/photoprism"
  originals      = "/user/photos/originals"
  import         = "/user/photos/import"
  backup         = "/user/photos/backup"
  mariadb_data   = "/var/lib/photoprism/mysql"

  // User
  admin_user     = "admin"
  admin_password = local.PHOTOPRISM_PASSWORD
}
