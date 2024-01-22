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
   * [Terraform Example](examples/seaweedfs/seaweedfs.tf)
   * [Nomad Job](seaweedfs/nomad/seaweedfs.hcl)

TODO:
  * [ ] In progress
  * [ ] A lot of testing is needed

## mosquitto

MQTT broker, which can be placed on several nodes

   * [Documentation](https://mosquitto.org/)
   * [Terraform Example](examples/mosquitto.tf)
   * [Nomad Job](mosquitto/nomad/mosquitto.hcl)

TODO:
  * [ ] Add TLS support

## OpenLDAP

OpenLDAP server, which can be placed on several nodes

   * [Documentation](https://www.openldap.org/)
   * [Terraform Example](examples/openldap.tf)
   * [Nomad Job](openldap/nomad/openldap.hcl)

TODO:
  * [ ] Add TLS support
  * [ ] Add replication support 
  * [ ] Add custom schema support

## InfluxDB

Time-series database, which can be placed on several nodes

   * [Documentation](https://docs.influxdata.com/influxdb/v2/)
   * [Terraform Example](examples/influxdb.tf)
   * [Nomad Job](influxdb/nomad/influxdb.hcl)

TODO:
  * [ ] Add TLS support

## telegraf

Time-series metrics collector, which can be placed on several nodes

   * [Documentation](https://docs.influxdata.com/telegraf/v1/)
   * [Terraform Example](examples/telegraf.tf)
   * [Nomad Job](telegraf/nomad/telegraf.hcl)

When setting up your configuration with inputs and outputs, each value needs
to be JSON encoded, so that the configuration can be passed as a map of strings,
as Terraform does not support maps of more than one type. See the terraform
example above for a demonstration of this.

TODO:
  * [ ] Add processors support

## semaphore

Semaphore is a Ansible front-end

   * [Documentation](https://www.semui.co/)
   * [Terraform Example](examples/semaphore.tf)
   * [Nomad Job](semaphore/nomad/semaphore.hcl)

TODO:
  * [ ] In progress
  * [ ] LDAP integration

## PostgreSQL

PostgreSQL is a database server

   * [Documentation](https://www.postgresql.org/)
   * [Terraform Example](examples/postgresql.tf)
   * [Nomad Job](postgresql/nomad/postgresql.hcl)

TODO:
  * [ ] LDAP integration


## grafana

grafana is a database server

   * [Documentation](https://grafana.com/docs/grafana/latest/)
   * [Terraform Example](examples/grafana.tf)
   * [Nomad Job](grafana/nomad/grafana.hcl)

TODO:
  * [ ] LDAP integration
  * [ ] Add TLS support
  * [ ] Data source provisioning
  * [ ] Dashboard provisioning
