locals {
  client_placement   = setproduct(google_compute_subnetwork.networks[*], range(var.client_node_count))
  segment_port_range = zipmap(google_compute_subnetwork.networks[*].name, (range(var.segment_start_port, length(google_compute_subnetwork.networks[*]) + var.segment_start_port, 1)))
}

provider "google" {
  credentials = file("${var.gcp_creds}")
  project     = var.gcp_project
  region      = var.region
  zone        = var.zone
}

resource "google_compute_instance" "server_instance" {
  count        = var.server_node_count
  name         = "${var.prefix}-server${count.index + 1}"
  machine_type = var.machine_type
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.networks[0].self_link
    access_config {
    }
  }
  metadata = {
    enable-guest-attributes = true,
    subnet-name             = google_compute_subnetwork.networks[0].self_link
  }
  provisioner "remote-exec" {
    connection {
      user        = var.ssh_username
      host        = self.network_interface[0].access_config[0].nat_ip
      private_key = file(var.private_key)
    }
    inline = []
  }
}

resource "google_compute_instance" "client_instance" {
  count        = length(google_compute_subnetwork.networks[*]) * var.client_node_count
  name         = "${var.prefix}-client${count.index + 1}"
  machine_type = var.machine_type
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  network_interface {
    subnetwork = element(local.client_placement, count.index)[0].self_link
    access_config {
    }
  }
  metadata = {
    enable-guest-attributes = true,
    subnet-name             = basename(element(local.client_placement, count.index)[0].self_link)
    consul-segment-port     = lookup(local.segment_port_range, basename(element(local.client_placement, count.index)[0].self_link))
  }
  provisioner "remote-exec" {
    connection {
      user        = var.ssh_username
      host        = self.network_interface[0].access_config[0].nat_ip
      private_key = file(var.private_key)
    }
    inline = []
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = var.prefix
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "networks" {
  count         = var.network_count
  name          = "${var.prefix}-network${count.index + 1}"
  ip_cidr_range = cidrsubnet(var.ip_cidr, 8, count.index)
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_firewall" "ssh_rules" {
  name          = "${var.prefix}-ssh-rules"
  network       = google_compute_network.vpc_network.name
  source_ranges = [var.admin_source_ip]
  allow {
    protocol = "tcp"
    ports    = ["22", "8500", "3000", "9090"]
  }
}

# Could add a loop for segment rules.  This doesn't impact the Consul network segments setup
resource "google_compute_firewall" "consul_rules" {
  name          = "${var.prefix}-consul-rules"
  network       = google_compute_network.vpc_network.name
  source_ranges = google_compute_subnetwork.networks[*].ip_cidr_range
  allow {
    protocol = "tcp"
  }
}

resource "null_resource" "server_instances" {
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -u '${var.ssh_username}' -i '${tostring(join(",", google_compute_instance.server_instance[*].network_interface[0].access_config[0].nat_ip))}' --private-key '${var.private_key}' provision.yml --extra-vars consul_server=true --extra-vars {\"node_server_ips\":'${tostring(format("%#v", google_compute_instance.server_instance[*].network_interface[0].network_ip))}}' --extra-vars '{\"network_segments\":${format("%#v", google_compute_subnetwork.networks[*].name)}}' --skip-tags single_node_cmds"
  }
}

resource "null_resource" "client_instances" {
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -u '${var.ssh_username}' -i '${tostring(join(",", google_compute_instance.client_instance[*].network_interface[0].access_config[0].nat_ip))}' --private-key '${var.private_key}' provision.yml --extra-vars consul_server=false --extra-vars {\"node_server_ips\":'${tostring(format("%#v", google_compute_instance.server_instance[*].network_interface[0].network_ip))}}' --extra-vars '{\"network_segments\":${format("%#v", google_compute_subnetwork.networks[*].name)}}' --skip-tags single_node_cmds"
  }
  depends_on = [null_resource.server_instances]
}

resource "null_resource" "single_node_cmds" {
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "if [ ! -z '${var.consul_license_blob}' ]; then ansible-playbook -u '${var.ssh_username}' -i '${google_compute_instance.server_instance[0].network_interface[0].access_config[0].nat_ip},' --private-key '${var.private_key}' provision.yml --extra-vars {\"node_server_ips\":'${tostring(format("%#v", google_compute_instance.server_instance[*].network_interface[0].network_ip))}}' --extra-vars consul_license_blob='${var.consul_license_blob}' --tags single_node_cmds; fi"
  }
  depends_on = [null_resource.server_instances]
}