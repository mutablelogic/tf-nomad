
output "port" {
  value = var.port
}

output "primary_services" {
  description = "Primary service DNS names"
  value       = local.primary_services
}

output "replica_services" {
  description = "Replica service DNS names"
  value       = local.replica_services
}
