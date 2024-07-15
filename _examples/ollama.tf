
// Example ollama module which uses the OpenAI API
// and deploys the webui
module "ollama" {
  source  = "github.com/mutablelogic/tf-nomad//ollama"
  enabled = true

  // Service parameters
  dc          = [var.dc]
  namespace   = var.namespace
  service_dns = local.COREDNS_DNS
  hosts       = ["cm2"] // Optional, deploys to a single node if not set
  hosts_webui = ["cm2"] // Optional, deploys to a single node if not set

  // Job parameters
  data           = "/var/lib/ollama"
  openai_api_key = local.OPENAI_API_KEY
}
