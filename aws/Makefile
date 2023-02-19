MKFILE := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
#PARENT_MKFILE   := $(HOME)/.Makefile # docker
PARENT_MKFILE   := $(MKFILE)/../../carlosrodlop/Makefile # local
DEBUG			:= true
ROOT_SHARED 	:= $(MKFILE)/root
ENV_SHARED		:= $(MKFILE)/env
# SOPS_KEY 	    := $(HOME)/.sops-age-key.txt
# DEC_KEY 	  	:= $(shell cat $(SOPS_KEY))
# ENC_KEY	  	  	:= $(shell age-keygen -y $(SOPS_KEY))

ROOT 			?= eks_bp_v4
BACKEND         ?= false

include $(PARENT_MKFILE)

export TF_LOG_PATH=terraform.log

ifeq ($(DEBUG),true)
	export TF_LOG=DEBUG
endif

#https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html
.PHONY: check_aws_env
check_aws_env: ## Check for the required environment variables
check_aws_env:
ifndef AWS_PROFILE
	@echo Warning: AWS_PROFILE Environment variable isn\'t defined and it is required for terraform apply\; Example: export AWS_PROFILE=exampleProfile
	@exit 1
endif
ifndef AWS_DEFAULT_REGION
	@echo Warning: AWS_DEFAULT_REGION Environment variable isn\'t defined and it is required for terraform apply\; Example: export AWS_DEFAULT_REGION=us-east-1
	@exit 1
endif

.PHONY: tf_init
tf_init: ## Init Terraform root passing as parameter (ROOT, default to aws). It can accept a remote BACKEND (default to false). Usage: ROOT=eks BACKEND=true make tf_init
tf_init: guard-ROOT guard-BACKEND
	$(call print_title,Init $(ROOT) resources)
ifeq ($(BACKEND),false)
	@terraform -chdir=$(ROOT_SHARED)/$(ROOT) fmt
	@terraform -chdir=$(ROOT_SHARED)/$(ROOT) init
	@terraform -chdir=$(ROOT_SHARED)/$(ROOT) validate
#else ifeq ($(ROOT),aws) #More detailed options
else #TODO Test this!
	@terraform -chdir=$(ROOT_SHARED)/$(ROOT) fmt
	@terraform -chdir=$(ROOT_SHARED)/$(ROOT) init \
		-backend-config="bucket=$(shell terraform -chdir=$(ROOT_SHARED) output --raw backend_name)" \
		-backend-config="region=$(shell terraform -chdir=$(ROOT_SHARED) output --raw aws_region)" \
		-backend-config="dynamodb_table=$(shell terraform -chdir=$(ROOT_SHARED) output --raw dynamo_table_lock_name)"
		-backend-config="key=state/$(ROOT).tfstate"
		-backend-config="kms_key_id=alias/$(ROOT)-bucket-key"
	@terraform -chdir=$(ROOT_SHARED)/$(ROOT) validate
endif

.PHONY: tf_apply
tf_apply: ## Apply Terraform root passing as parameter (ROOT, default to aws). Usage: ROOT=eks make tf_apply
tf_apply: check_aws_env guard-ROOT
	@rm -rf $(TF_LOG_PATH)
	$(call print_title,Apply $(ROOT) resources) | tee -a $(TF_LOG_PATH)
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) plan -out="$(ROOT).plan" -var-file="$(ENV_SHARED)/shared.tfvars"
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) apply "$(ROOT).plan"

.PHONY: tf_destroy
tf_destroy: ## Destroy Terraform root passing as parameter (ROOT, default to aws). Usage: ROOT=eks_bp_v4-eks make tf_destroy
tf_destroy: guard-ROOT check_aws_env
	$(call print_title,Destroy $(ROOT) Cluster) |tee -a $(TF_LOG_PATH)
	@rm -rf $(TF_LOG_PATH)
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -target=module.eks_blueprints_kubernetes_addons -var-file="$(ENV_SHARED)/shared.tfvars"
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -target=module.eks_blueprints -var-file="$(ENV_SHARED)/shared.tfvars"
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -target=module.vpc -var-file="$(ENV_SHARED)/shared.tfvars"
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -var-file="$(ENV_SHARED)/shared.tfvars"
