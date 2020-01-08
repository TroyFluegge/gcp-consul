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