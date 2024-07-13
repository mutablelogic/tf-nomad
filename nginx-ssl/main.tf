
resource "nomad_job" "nginx-ssl" {
  count   = var.enabled ? 1 : 0
  jobspec = file("${path.module}/nomad/nginx-ssl.hcl")

  hcl2 {
    allow_fs = true
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      hosts              = jsonencode(var.hosts)
      docker_image       = local.docker_image
      docker_always_pull = jsonencode(local.docker_always_pull)
      service_provider   = var.service_provider
      service_dns        = jsonencode(var.service_dns)
      service_name       = var.service_name
      hosts              = jsonencode(var.hosts)
      ports              = jsonencode(var.ports)
      configs = jsonencode({
        "nginx.conf"     = chomp(file("${path.module}/config/nginx.conf"))
        "ssl.conf"       = chomp(file("${path.module}/config/ssl.conf"))
        "mimetypes.conf" = chomp(file("${path.module}/config/mimetypes.conf"))
        "fastcgi.conf"   = chomp(file("${path.module}/config/fastcgi.conf"))
        "http.conf"      = chomp(file("${path.module}/config/http.conf"))
        "proxy.conf"     = chomp(file("${path.module}/config/proxy.conf"))
      })
      servers            = jsonencode(var.servers)
      timezone           = var.timezone
      zone               = var.zone
      email              = var.email
      subdomains         = jsonencode(var.subdomains)
      dns_validation     = var.dns_validation
      cloudflare_api_key = var.cloudflare_api_key
      staging            = var.staging
    }
  }
}
