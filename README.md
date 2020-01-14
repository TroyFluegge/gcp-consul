# Consul Network Segments Demo in GCP

This is a completely automated way to deploy Consul with multiple network segments.  This is an Enterprise feature that you can read more about [here]([https://www.consul.io/docs/enterprise/network-segments/index.html](https://www.consul.io/docs/enterprise/network-segments/index.html)) or go through the learn material [here](https://learn.hashicorp.com/consul/day-2-operations/network-segments).  It will create a three server node cluster with two networks and two client nodes per network for a total of 4 client nodes.  Currently the firewall is not setting restrictive rules between these segments, which you would typically see in a large enterprise.  Maybe I will add them at a later time to make it more accurate to an enterprise environment.  With that said, the Consul configuration is setup as if there were more restrictive rules and will keep LAN gossip traffic to the assigned network segment.

This project uses Ansible in a null_resource local-exec provisioner.  Everytime you run a `terraform apply`, it will rerun the the local-exec provisioners.  This is handy if you make variable changes and just want to apply the updates without destroying everything.  This also means that you are running Ansible locally and will need it installed.

Run the normal Terraform commands and you should be good to go!

`terraform init`

`terraform plan`

`terraform apply`

I added prometheus and grafana containers onto one of the nodes.  The outputs will output the url and port.  There isn't much going on there yet.  I plan to add some custom dashboards to display gossip errors due to network segmentation and how network segments fixes those types of issues.  Right now, you can add a prometheus datasource in grafana buy using the internal IP of the prometheus server `http://10.10.0.2:9090` (if you didn't change the CIDR range).  Then you can make any dashboard you want with that datasource.

Requirements:
* Terraform version >= 0.12
* Ansible (I used version 2.9.2)
* Optional: Consul Enterprise License
  - Service is timeboxed to 30 mins without one

|Variables|Description                  | Default Value
|------------------------------|-----------------------------|------------------------------|
|gcp_project|GCP  Project  to  deploy  too (Required)|No Default
|admin_source_ip|Inbound  source  IP  to  your  environment  in  CIDR  notation  ex.  169.254.169.254/32.  Run 'curl  icanhazip.com' (Required)|No Default
|ssh_username|What  username  to  use  for  SSH  connections (Required)|No Default
|gcp_creds|Path  to  your  GCP  credential  file (Required)|~/.gcp/credentials.json
|consul_license_blob|If  a  license  blob  is  defined, it  will  be  applied.  If  left  null, you  will  have  a  30  minute  timeout  on  the  Enterprise  binary| null
|prefix|Prefix assigned to all resources|consuldemo
|private_key|Private  key  to  use  for  SSH.  Public key must be in your project metadata (Required)|~/.ssh/id_rsa
|region|GCP  Region|us-central1
|zone|GCP Zone|us-central1-a
|ip_cidr|Network IP CIDR block for the VPC|10.10.0.0/16
|machine_type|GCP  instance  type|n1-standard-1
|server_node_count|The  number  of  Consul  server  nodes.  Minimum  of  3  nodes| 3
|client_node_count|The  number  of  Consul  client  nodes  per  network  count.  Minimum  of  2  nodes|2
|network_count|The  number  of  network  segments.  Each  network  will  have {{ client_node_count }} number  of  clients|2
|segment_start_port|Each  consul  segment  needs  unique  TCP  ports  to  connect  to  server  side.  This  is  the  starting  port  number.  Each  segment  will  increase  by  one|8303

**I would recommend setting your consul_license_blob as a environment variable so you don't inadvertently commit it to a public repository.**
>export TF_VAR_consul_license_blob=xxxxxxxxxxxxxxxxxxxxx