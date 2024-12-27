
resource "nomad_job" "seaweedfs-master" {
  for_each = var.enabled ? var.masters : {}
  jobspec = templatefile("${path.module}/nomad/master.hcl", {
    name = each.value.name
  })

  hcl2 {
    allow_fs = true
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      service_provider   = var.service_provider
      service_name       = var.service_name
      service_dns        = jsonencode(var.service_dns)
      docker_image       = local.docker_image
      docker_always_pull = local.docker_always_pull
      ip                 = each.key
      peers              = jsonencode(local.master_peers)
      data               = each.value.data
      port               = var.http_port_master
      grpc_port          = var.grpc_port_master == 0 ? var.http_port_master + local.grpc_offset : var.grpc_port_master
      metrics_port       = var.metrics ? var.metrics_port_master : 0
      replication        = var.replication
    }
  }
}

resource "nomad_job" "seaweedfs-volume" {
  for_each = var.enabled ? var.volumes : {}
  jobspec = templatefile("${path.module}/nomad/volume.hcl", {
    name = each.value.name
  })

  hcl2 {
    allow_fs = true
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      service_provider   = var.service_provider
      service_name       = var.service_name
      service_dns        = jsonencode(var.service_dns)
      docker_image       = local.docker_image
      docker_always_pull = local.docker_always_pull
      ip                 = each.key
      masters            = jsonencode(local.master_peers)
      data               = jsonencode(each.value.data)
      port               = var.http_port_volume
      grpc_port          = var.grpc_port_volume == 0 ? var.http_port_volume + local.grpc_offset : var.grpc_port_volume
      metrics_port       = var.metrics ? var.metrics_port_volume : 0
      rack               = each.value.rack
      public_url         = each.value.public_url
    }
  }
}

resource "nomad_job" "seaweedfs-filer" {
  for_each = var.enabled ? var.filers : {}
  jobspec = templatefile("${path.module}/nomad/filer.hcl", {
    name = each.value.name
  })

  hcl2 {
    allow_fs = true
    vars = {
      dc                 = jsonencode([var.dc])
      namespace          = var.namespace
      service_provider   = var.service_provider
      service_name       = var.service_name
      service_dns        = jsonencode(var.service_dns)
      docker_image       = local.docker_image
      docker_always_pull = local.docker_always_pull
      ip                 = each.key
      masters            = jsonencode(local.master_peers)
      data               = jsonencode(each.value.data)
      port               = var.http_port_filer
      grpc_port          = var.grpc_port_filer == 0 ? var.http_port_filer + local.grpc_offset : var.grpc_port_filer
      metrics_port       = var.metrics ? var.metrics_port_filer : 0
      webdav_port        = each.value.webdav ? var.webdav_port_filer : 0
      s3_port            = each.value.s3 ? var.s3_port_filer : 0
      rack               = each.value.rack
      collection         = each.value.collection
    }
  }
}
