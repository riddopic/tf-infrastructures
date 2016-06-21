# encoding: UTF-8
#
# Makefile to kick of the terraform for this project.
#
# You should set the following environment variable to authenticate with AWS so
# you can store and retrieve the remote state befor you run this Makefile.
#
# export AWS_ACCESS_KEY_ID= <your key>
# export AWS_SECRET_ACCESS_KEY= <your secret>
# export AWS_DEFAULT_REGION= <your bucket region eg ap-southeast-2>
# export ATLAS_USERNAME= <your username>
# export ATLAS_TOKEN= <you token>
#
################################################################################

# Working Directories
ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BUILD    := $(ROOT_DIR)terraform/providers/aws/us_west_2_dev/

# Terraform files
TF_PORVIDER         := $(BUILD)/provider.tf
TF_DESTROY_PLAN_OUT := $(BUILD)/destroy.tfplan
TF_APPLY_PLAN       := $(BUILD)/apply.tfplan
TF_STATE            := $(BUILD)/terraform.tfstate

# NOTE: for production, set -refresh=true to be safe and remove --force to
# confirm destroy.
TF_APPLY         := terraform apply -refresh=false
TF_DESTROY       := terraform destroy --force
TF_DESTROY_PLAN  := terraform plan -destroy -refresh=false
TF_GET           := terraform get -update > /dev/null 2>&1
TF_GRAPH         := terraform graph -draw-cycles -verbose
TF_PLAN          := terraform plan -module-depth=1 -refresh=false
TF_SHOW          := terraform show -module-depth=1
TF_REFRESH       := terraform refresh
TF_TAINT         := terraform taint -allow-missing
# cidr block to allow ssh
# TF_VAR_allow_ssh_cidr := $(curl -s http://ipinfo.io/ip)/32

define message
	@printf "\n\e[33m******************* \e[32m"
	@printf $1
	@printf " \e[33m******************* \e[32m\n\n"
endef

export

all: plan

apply: plan
	$(call message, "terraform apply")
	cd $(BUILD); $(TF_APPLY)

plan: init
	$(call message, "terraform plan")
	cd $(BUILD); $(TF_PLAN)

init:
	cd $(BUILD); $(TF_GET)

destroy: plan_destroy
	$(call message, "terraform destroy")
	cd $(BUILD); $(TF_DESTROY)

plan_destroy:
	$(call message, "terraform plan destroy")
	cd $(BUILD); $(TF_DESTROY_PLAN)

.PHONY: all apply plan destroy plan_destroy
