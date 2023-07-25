MKFILE := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile
ROOT_SHARED 	:= $(MKFILE)/root
ENV_SHARED		:= $(MKFILE)/env
TIMESTAMP		:= $(shell date +%Y%m%d%H%M)

include $(PARENT_MKFILE)

DEBUG			:= $(shell echo $(call getEnvProperty,DEBUG))
AUTOPROVE	    := $(shell echo $(call getEnvProperty,AUTOPROVE))
BACKEND         ?= $(shell echo $(call getEnvProperty,BACKEND))
AWS_RESOURCES  	:= $(shell echo $(call getEnvProperty,AWS_RESOURCES))
K8S_RESOURCES  	:= $(shell echo $(call getEnvProperty,K8S_RESOURCES))
ROOT 			?= $(shell echo $(call getEnvProperty,ROOT))
# SOPS_KEY 	    := $(HOME)/.sops-age-key.txt
# DEC_KEY 	  	:= $(shell cat $(SOPS_KEY))
# ENC_KEY	  	:= $(shell age-keygen -y $(SOPS_KEY))

export TF_LOG_PATH=terraform.log

ifeq ($(DEBUG),true)
	export TF_LOG=DEBUG
endif

#https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html
.PHONY: check_aws_env
check_aws_env: ## Check for the required environment variables
check_aws_env:
	$(call exitsEnvVariable,AWS_PROFILE,export AWS_PROFILE=example-profile)
	$(call exitsEnvVariable,AWS_DEFAULT_REGION,export AWS_DEFAULT_REGION=us-east-1)

.PHONY: tf_init
tf_init: ## Init Terraform root passing as parameter. It can accept a remote BACKEND (default to false). Usage: ROOT=eks BACKEND=true make tf_init
tf_init: guard-ROOT guard-BACKEND
	$(call print_title,Init $(ROOT) resources)
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) fmt
ifeq ($(BACKEND),true) #IMPORTANT: It requires backend.tf file in the root folder
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) init -migrate-state \
		-backend-config="bucket=$(shell echo $(call getTFValue,$(ROOT_SHARED)/state-bucket,backend_name))" \
		-backend-config="region=$(shell echo $(call getTFValue,$(ROOT_SHARED)/state-bucket,aws_region))" \
		-backend-config="dynamodb_table=$(shell echo $(call getTFValue,$(ROOT_SHARED)/state-bucket,dynamo_table_lock_name))" \
		-backend-config="key=state/$(AWS_RESOURCES).tfstate" \
		-backend-config="encrypt=true"
else
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) init
endif
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) validate

.PHONY: tf_apply
tf_apply: ## Apply Terraform root passing as parameter (ROOT, default to eks-bp-v4). Usage: ROOT=eks-bp-v4 make tf_apply
tf_apply: check_aws_env guard-ROOT
	@rm -rf $(TF_LOG_PATH)
	$(call print_title,Apply $(ROOT) resources) | tee -a $(TF_LOG_PATH)
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) plan -out="$(TIMESTAMP)-$(ROOT).plan" -var-file="$(ENV_SHARED)/shared.tfvars"
ifeq ($(AUTOPROVE),true)
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) apply "$(TIMESTAMP)-$(ROOT).plan"
else
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) apply
endif

.PHONY: tf_cleanup_plans
tf_cleanup_plans: ## Delete Old plans for ROOT passed as parameter. Usage: ROOT=eks-bp-v4 make tf_apply
tf_cleanup_plans: guard-ROOT
	@rm -rf $(ROOT_SHARED)/$(ROOT)/*.plan

.PHONY: tf_destroy
tf_destroy: ## Destroy Terraform root passing as parameter (ROOT, default to eks-bp-v4). Usage: ROOT=eks-bp-v4 make tf_destroy
tf_destroy: guard-ROOT check_aws_env
	$(call print_title,Destroy $(ROOT) Cluster) | tee -a $(TF_LOG_PATH)
	rm -rf $(TF_LOG_PATH)
ifeq ($(ROOT),$(K8S_RESOURCES))
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -target=module.eks_blueprints_kubernetes_addons -var-file="$(ENV_SHARED)/shared.tfvars"
else ifeq ($(ROOT),$(AWS_RESOURCES))
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -target=module.eks -var-file="$(ENV_SHARED)/shared.tfvars"
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -target=module.vpc -var-file="$(ENV_SHARED)/shared.tfvars"
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -var-file="$(ENV_SHARED)/shared.tfvars"
else
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -var-file="$(ENV_SHARED)/shared.tfvars"
endif
