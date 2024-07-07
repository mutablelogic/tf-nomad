
locals {
  docker_image       = "chrislusf/seaweedfs:${var.docker_tag}"
  docker_always_pull = var.docker_tag == "latest" ? true : false
  grpc_offset        = 100
  master_peers = [
    for ip, attr in var.masters : format("%s:%d.%d", ip, var.http_port_master, var.grpc_port_master == 0 ? var.http_port_master + local.grpc_offset : var.grpc_port_master)
  ]
}
