# encoding: UTF-8

variable "name"                       { }
variable "artifact_type"              { }
variable "region"                     { }
variable "sub_domain"                 { }
variable "atlas_environment"          { }
variable "atlas_aws_global"           { }
variable "atlas_token"                { }
variable "atlas_username"             { }
variable "site_public_key"            { }
variable "site_private_key"           { }
variable "site_ssl_cert"              { }
variable "site_ssl_key"               { }
variable "vault_ssl_cert"             { }
variable "vault_ssl_key"              { }
variable "vault_token"                { default = "" }

variable "vpc_cidr"                   { }
variable "azs"                        { }
variable "private_subnets"            { }
variable "ephemeral_subnets"          { }
variable "public_subnets"             { }

variable "bastion_instance_type"      { }

variable "openvpn_instance_type"      { }
variable "openvpn_ami"                { }
variable "openvpn_user"               { }
variable "openvpn_admin_user"         { }
variable "openvpn_admin_pw"           { }
variable "openvpn_cidr"               { }

variable "consul_node_count"          { }
variable "consul_instance_type"       { }
variable "consul_artifact_name"       { }
variable "consul_artifacts"           { }

variable "vault_node_count"           { }
variable "vault_instance_type"        { }
variable "vault_artifact_name"        { }
variable "vault_artifacts"            { }

variable "haproxy_node_count"         { }
variable "haproxy_instance_type"      { }
variable "haproxy_artifact_name"      { }
variable "haproxy_artifacts"          { }

variable "nodejs_blue_node_count"     { }
variable "nodejs_blue_instance_type"  { }
variable "nodejs_blue_weight"         { }
variable "nodejs_green_node_count"    { }
variable "nodejs_green_instance_type" { }
variable "nodejs_green_weight"        { }
variable "nodejs_artifact_name"       { }
variable "nodejs_artifacts"           { }
