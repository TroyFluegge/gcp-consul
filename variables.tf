variable "gcp_project" {
  description = "GCP Project to deploy too"
}

variable "admin_source_ip" {
  description = "Inbound source IP to your environment in CIDR notation ex. 169.254.169.254/32. Run 'curl icanhazip.com'"
}

variable "ssh_username" {
  description = "What username to use for SSH connections"
}

variable "gcp_creds" {
  description = "Path to your GCP credential file"
  default     = "~/.gcp/credentials.json"
}

variable "consul_license_blob" {
  description = "If a license blob is defined, it will be applied.  If left null, you will have a 30 minute timeout on the Enterprise binary"
  default     = ""
}

variable "prefix" {
  description = "Make resource names unique"
  default     = "consuldemo"
}

variable "private_key" {
  description = "Private key to use for SSH"
  default     = "~/.ssh/id_rsa"
}

variable "region" {
  description = "GCP Region"
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  default     = "us-central1-a"
}

variable "ip_cidr" {
  description = "Network IP CIDR block"
  default     = "10.10.0.0/16"
}

variable "machine_type" {
  description = "GCP instance type"
  default     = "n1-standard-1"
}

variable "server_node_count" {
  description = "The number of Consul server nodes.  Minimum of 3 nodes"
  default     = "3"
}

variable "client_node_count" {
  description = "The number of Consul client nodes per network count.  Minimum of 2 nodes"
  default     = "2"
}

variable "network_count" {
  description = "The number of network segments. Each network will have {{ client_node_count }} number of clients"
  default     = "2"
}
