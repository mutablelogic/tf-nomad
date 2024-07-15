
output "enabled" {
  value = var.enabled
}

output "service-http" {
  value = {
    name = format("%s-%s.%s.%s.", var.service_name, "http", var.namespace, "nomad")
    port = var.port
  }
}

output "service-webui-http" {
  value = {
    name = format("%s-webui-%s.%s.%s.", var.service_name, "http", var.namespace, "nomad")
    port = var.port_webui
  }
}
