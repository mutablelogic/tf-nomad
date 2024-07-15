
///////////////////////////////////////////////////////////////////////////////
// VARIABLES

variable "dc" {
  description = "data centers that the job is eligible to run in"
  type        = list(string)
}

variable "namespace" {
  description = "namespace that the job runs in"
  type        = string
  default     = "default"
}

variable "enabled" {
  type        = bool
  description = "If false, then no job is deployed"
  default     = true
}

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "ollama"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "docker_tag" {
  type        = string
  description = "Version of the docker image to use, defaults to latest"
  default     = "latest"
}

variable "docker_tag_webui" {
  type        = string
  description = "Version of the docker image to use for webui, set to empty string to disable"
  default     = "main"
}

///////////////////////////////////////////////////////////////////////////////

variable "hosts" {
  description = "List of hosts to deploy ollama on. If empty, one allocation will be created"
  type        = list(string)
  default     = []
}

variable "hosts_webui" {
  description = "List of hosts to deploy webui on. If empty, one allocation will be created"
  type        = list(string)
  default     = []
}

variable "port" {
  description = "Ollama port to expose"
  type        = number
  default     = 11434
}

variable "port_webui" {
  description = "WebUI port to expose"
  type        = number
  default     = 11435
}

variable "data" {
  description = "Persistent data path"
  type        = string
  default     = "ollama"
}

variable "devices" {
  description = "Devices to expose"
  type        = list(string)
  default     = []
}

variable "openai_api_key" {
  description = "OpenAI API Key"
  type        = string
  sensitive   = true
  default     = ""
}
