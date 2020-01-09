#
# Required variables listed below.  Defaults are not set for these
#
# gcp_creds = {{ path to your json cred file }}   # Defaults to ~/.gcp/credentials.json 
# consul_license_blob can be defined for the Enterprise features.  Consul will run for 30 minutes without a license
# It is recommended to set this as an environment variable.  'export TF_VAR_consul_license_blob={{ license_blob }}'
#

# gcp_project = {{ GCP Project Name }}
# admin_source_ip = {{ admin external NAT IP }}
# ssh_username = {{ ssh username }}

# Default client and network counts are also 2 x 2.  The number of clients created are per network.  In this case, 4 total clients.  2 per network

client_node_count = 2
network_count = 2