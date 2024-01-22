# tf-nomad

Terraform modules for nomad clusters. In order to use these modules, please use
the following provider block:

```hcl
terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.0.0"
    }
  }
}

provider "nomad" {
  address   = env.NOMAD_ADDR
  region    = env.NOMAD_REGION
  secret_id = env.NOMAD_TOKEN
}
```

## seaweedfs

Cluster filesystem, which can be spread across multiple nodes.

   * [Documentation](https://github.com/seaweedfs/seaweedfs)
   * [Terraform Example](examples/seaweedfs/clusterfs.tf)
   * [Nomad Job](seaweedfs/nomad/seaweedfs.hcl)


TODO:
  * [ ] A lot of testing is needed

## mosquitto

MQTT broker, which can be placed on several nodes

   * [Documentation](https://mosquitto.org/)
   * [Terraform Example](examples/mosquitto/mosquitto.tf)
   * [Nomad Job](mosquitto/nomad/mosquitto.hcl)

TODO:
  * [ ] Add TLS support

## LDAP

LDAP server, which can be placed on several nodes

   * [Documentation](https://www.openldap.org/)
   * [Terraform Example](examples/ldap/ldap.tf)
   * [Nomad Job](ldap/nomad/ldap.hcl)

TODO:
  * [ ] Add TLS support
  * [ ] Add replication support 
  * [ ] Add custom schema support
