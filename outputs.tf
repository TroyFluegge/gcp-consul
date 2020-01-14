output "server_ext_ips" {
  description = "External IP's of all the Consul servers"
  value       = format("%#v", google_compute_instance.server_instance[*].network_interface[0].access_config[0].nat_ip)
}

output "server_int_ips" {
  description = "Internal IP's of all the Consul servers"
  value       = format("%#v", google_compute_instance.server_instance[*].network_interface[0].network_ip)
}

output "client_ext_ips" {
  description = "External IP's of all the Consul clients"
  value       = format("%#v", google_compute_instance.client_instance[*].network_interface[0].access_config[0].nat_ip)
}

output "client_int_ips" {
  description = "Internal IP's of all the Consul clients"
  value       = format("%#v", google_compute_instance.client_instance[*].network_interface[0].network_ip)
}

output "consul_ui" {
  description = "URL to the Consul UI"
  value       = "http://${google_compute_instance.server_instance[0].network_interface[0].access_config[0].nat_ip}:8500/ui"
}

output "grafana_ui" {
  description = "URL to the Consul UI"
  value       = "http://${google_compute_instance.server_instance[0].network_interface[0].access_config[0].nat_ip}:3000"
}

output "prometheus_ui" {
  description = "URL to the Consul UI"
  value       = "http://${google_compute_instance.server_instance[0].network_interface[0].access_config[0].nat_ip}:9090"
}