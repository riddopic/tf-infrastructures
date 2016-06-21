
provider "aws" {
  region = "${var.region}"
}

atlas {
  name = "${var.atlas_username}/${var.atlas_environment}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.atlas_environment}"
  public_key = "${var.site_public_key}"

  lifecycle { create_before_destroy = true }
}

resource "terraform_remote_state" "aws_global" {
  backend = "atlas"

  config {
    name = "${var.atlas_username}/${var.atlas_aws_global}"
  }

  lifecycle { create_before_destroy = true }
}

module "network" {
  source                     = "../../../modules/aws/network"

  name                       = "${var.name}"
  vpc_cidr                   = "${var.vpc_cidr}"
  azs                        = "${var.azs}"
  region                     = "${var.region}"
  private_subnets            = "${var.private_subnets}"
  ephemeral_subnets          = "${var.ephemeral_subnets}"
  public_subnets             = "${var.public_subnets}"
  ssl_cert                   = "${var.site_ssl_cert}"
  ssl_key                    = "${var.site_ssl_key}"
  key_name                   = "${aws_key_pair.site_key.key_name}"
  private_key                = "${var.site_private_key}"
  sub_domain                 = "${var.sub_domain}"
  route_zone_id              = "${terraform_remote_state.aws_global.output.zone_id}"

  bastion_instance_type      = "${var.bastion_instance_type}"
  openvpn_instance_type      = "${var.openvpn_instance_type}"
  openvpn_ami                = "${var.openvpn_ami}"
  openvpn_user               = "${var.openvpn_user}"
  openvpn_admin_user         = "${var.openvpn_admin_user}"
  openvpn_admin_pw           = "${var.openvpn_admin_pw}"
  openvpn_cidr               = "${var.openvpn_cidr}"
}

module "artifact_consul" {
  source                     = "../../../modules/aws/util/artifact"

  type                       = "${var.artifact_type}"
  region                     = "${var.region}"
  atlas_username             = "${var.atlas_username}"
  artifact_name              = "${var.consul_artifact_name}"
  artifact_version           = "${var.consul_artifacts}"
}

module "artifact_vault" {
  source                     = "../../../modules/aws/util/artifact"

  type                       = "${var.artifact_type}"
  region                     = "${var.region}"
  atlas_username             = "${var.atlas_username}"
  artifact_name              = "${var.vault_artifact_name}"
  artifact_version           = "${var.vault_artifacts}"
}

module "data" {
  source                     = "../../../modules/aws/data"

  name                       = "${var.name}"
  region                     = "${var.region}"
  vpc_id                     = "${module.network.vpc_id}"
  vpc_cidr                   = "${var.vpc_cidr}"
  private_subnet_ids         = "${module.network.private_subnet_ids}"
  public_subnet_ids          = "${module.network.public_subnet_ids}"
  ssl_cert                   = "${var.vault_ssl_cert}"
  ssl_key                    = "${var.vault_ssl_key}"
  key_name                   = "${aws_key_pair.site_key.key_name}"
  atlas_username             = "${var.atlas_username}"
  atlas_environment          = "${var.atlas_environment}"
  atlas_token                = "${var.atlas_token}"
  sub_domain                 = "${var.sub_domain}"
  route_zone_id              = "${terraform_remote_state.aws_global.output.zone_id}"

  consul_amis                = "${module.artifact_consul.amis}"
  consul_node_count          = "${var.consul_node_count}"
  consul_instance_type       = "${var.consul_instance_type}"
  openvpn_user               = "${var.openvpn_user}"
  openvpn_host               = "${module.network.openvpn_private_ip}"
  private_key                = "${var.site_private_key}"
  bastion_host               = "${module.network.bastion_public_ip}"
  bastion_user               = "${module.network.bastion_user}"

  vault_amis                 = "${module.artifact_vault.amis}"
  vault_node_count           = "${var.vault_node_count}"
  vault_instance_type        = "${var.vault_instance_type}"
}

module "artifact_haproxy" {
  source                     = "../../../modules/aws/util/artifact"

  type                       = "${var.artifact_type}"
  region                     = "${var.region}"
  atlas_username             = "${var.atlas_username}"
  artifact_name              = "${var.haproxy_artifact_name}"
  artifact_version           = "${var.haproxy_artifacts}"
}

module "artifact_nodejs" {
  source                     = "../../../modules/aws/util/artifact"

  type                       = "${var.artifact_type}"
  region                     = "${var.region}"
  atlas_username             = "${var.atlas_username}"
  artifact_name              = "${var.nodejs_artifact_name}"
  artifact_version           = "${var.nodejs_artifacts}"
}

module "compute" {
  source                     = "../../../modules/aws/compute"

  name                       = "${var.name}"
  region                     = "${var.region}"
  vpc_id                     = "${module.network.vpc_id}"
  vpc_cidr                   = "${var.vpc_cidr}"
  key_name                   = "${aws_key_pair.site_key.key_name}"
  azs                        = "${var.azs}"
  private_subnet_ids         = "${module.network.private_subnet_ids}"
  public_subnet_ids          = "${module.network.public_subnet_ids}"
  site_ssl_cert              = "${var.site_ssl_cert}"
  site_ssl_key               = "${var.site_ssl_key}"
  vault_ssl_cert             = "${var.vault_ssl_cert}"
  atlas_username             = "${var.atlas_username}"
  atlas_environment          = "${var.atlas_environment}"
  atlas_aws_global           = "${var.atlas_aws_global}"
  atlas_token                = "${var.atlas_token}"
  sub_domain                 = "${var.sub_domain}"
  route_zone_id              = "${terraform_remote_state.aws_global.output.zone_id}"
  vault_token                = "${var.vault_token}"

  haproxy_amis               = "${module.artifact_haproxy.amis}"
  haproxy_node_count         = "${var.haproxy_node_count}"
  haproxy_instance_type      = "${var.haproxy_instance_type}"

  nodejs_blue_ami            = "${element(split(",", module.artifact_nodejs.amis), 0)}"
  nodejs_blue_node_count     = "${var.nodejs_blue_node_count}"
  nodejs_blue_instance_type  = "${var.nodejs_blue_instance_type}"
  nodejs_blue_weight         = "${var.nodejs_blue_weight}"
  nodejs_green_ami           = "${element(split(",", module.artifact_nodejs.amis), 1)}"
  nodejs_green_node_count    = "${var.nodejs_green_node_count}"
  nodejs_green_instance_type = "${var.nodejs_green_instance_type}"
  nodejs_green_weight        = "${var.nodejs_green_weight}"

}

module "website" {
  source        = "../../../modules/aws/util/website"

  fqdn          = "${var.sub_domain}.${terraform_remote_state.aws_global.output.prod_fqdn}"
  sub_domain    = "${var.sub_domain}"
  route_zone_id = "${terraform_remote_state.aws_global.output.zone_id}"
}
