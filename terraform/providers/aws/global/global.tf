# encoding: UTF-8

provider "aws" {
  region     = "${var.region}"
}

atlas {
  name       = "${var.atlas_username}/${var.atlas_environment}"
}

module "iam_admin" {
  source     = "../../../modules/aws/util/iam"

  name       = "${var.name}-admin"
  users      = "${var.iam_admins}"
  policy     = <<EOF
{
  "Version"  : "2012-10-17",
  "Statement": [
    {
      "Effect"  : "Allow",
      "Action"  : "*",
      "Resource": "*"
    }
  ]
}
EOF
}

module "iam_vault" {
  source     = "../../../modules/aws/util/iam"

  name       = "${var.name}-vault"
  users      = "${var.iam_vault_envs}"
  policy     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:PutUserPolicy",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:DeleteAccessKey",
        "iam:DeleteUserPolicy",
        "iam:RemoveUserFromGroup",
        "iam:DeleteUser"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_route53_zone" "zone" {
  name          = "${var.domain}"
}

module "prod_website" {
  source        = "../../../modules/aws/util/website"

  route_zone_id = "${aws_route53_zone.zone.zone_id}"
  fqdn          = "${var.domain}"
  sub_domain    = "${var.domain}"
}

module "staging_website" {
  source        = "../../../modules/aws/util/website"

  route_zone_id = "${aws_route53_zone.zone.zone_id}"
  fqdn          = "staging.${var.domain}"
  sub_domain    = "staging"
}
