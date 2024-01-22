# tf-nomad

Terraform modules for nomad clusters

## seaweedfs

Cluster filesystem, which can be spread across multiple nodes.

   * [Documentation](https://github.com/seaweedfs/seaweedfs)
   * [Terraform Example](examples/seaweedfs/clusterfs.tf)
   * [Nomad Job](seaweedfs/nomad/seaweedfs.hcl)

## mosquitto

MQTT broker, which can be placed on several nodes

   * [Documentation](https://mosquitto.org/)
   * [Terraform Example](examples/mosquitto/mosquitto.tf)
   * [Nomad Job](mosquitto/nomad/mosquitto.hcl)

