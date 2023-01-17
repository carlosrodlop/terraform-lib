MKFILE_EKS_LABS := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
#PARENT_MKFILE   := $(HOME)/.Makefile # docker
PARENT_MKFILE   := $(MKFILE_EKS_LABS)/../carlosrodlop/Makefile # local
DEBUG			:= true
ROOT_EKS_LABS 	:= $(MKFILE_EKS_LABS)/shared/tf
ENV_EKS_LABS	:= $(MKFILE_EKS_LABS)/shared/env
CB_EKS_LABS		:= $(MKFILE_EKS_LABS)/shared/cb

include $(PARENT_MKFILE)

export TF_LOG_PATH=$(ROOT_EKS_LABS)/terraform.log

ifeq ($(DEBUG),true)
	export TF_LOG=DEBUG
endif

#https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html
.PHONY: check_aws_profile
check_aws_profile: ## Check for the required environment variables
check_aws_profile:
ifndef AWS_PROFILE
	@echo Warning: AWS_PROFILE Environment variable isn\'t defined and it is required for terraform apply\; Example: export AWS_PROFILE=exampleProfile
	@exit 1
endif

.PHONY: tf_init_shared
tf_init_shared: ## Init Common Terraform modules for the labs
tf_init_shared: guard-ROOT
	$(call print_title,Init $(ROOT) resources)
	@terraform -chdir=$(ROOT_EKS_LABS)/$(ROOT) fmt
	@terraform -chdir=$(ROOT_EKS_LABS)/$(ROOT) init -upgrade=true
	@terraform -chdir=$(ROOT_EKS_LABS)/$(ROOT) validate

.PHONY: tf_apply_shared
tf_apply_shared: ## Apply Common Terraform modules for the labs
tf_apply_shared: guard-ROOT
	@rm -rf $(TF_LOG_PATH)
	$(call print_title,Apply $(ROOT) resources) |tee -a $(TF_LOG_PATH)
	@terraform -chdir=$(ROOT_EKS_LABS)/$(ROOT) plan -out="$(ROOT).plan" -var-file="$(ENV_EKS_LABS)/shared.tfvars" -input=false
	@terraform -chdir=$(ROOT_EKS_LABS)/$(ROOT) apply "$(ROOT).plan"

.PHONY: tf_destroy_shared
tf_destroy_shared: ## Destroy Common Terraform modules for the labs
tf_destroy_shared: guard-ROOT
	@rm -rf $(TF_LOG_PATH)
	$(call print_title,Destroy $(ROOT) resources) |tee -a $(TF_LOG_PATH)
	@terraform -chdir=$(ROOT_EKS_LABS)/$(ROOT) destroy -var-file="$(ENV_EKS_LABS)/shared.tfvars"

.PHONY: sops-encription
sops-encription: ## Encript file with SOPS. Upload to GitHub
sops-encription:
	$(call print_title,Encrypting via SOPS)
	@cd $(CB_EKS_LABS)/secrets && SOPS_AGE_RECIPIENTS=$(ENC_KEY) sops -e cbci-secrets.yaml > cbci-secrets.yaml.enc

.PHONY: sops-decription
sops-decription: ## Decript file with SOPS. Include them in .gitignore
sops-decription:
	$(call print_title,Decrypting via SOPS)
	@cd $(CB_EKS_LABS)/.docker/tf/v_kube && SOPS_AGE_KEY=$(DEC_KEY) sops -d cbci-secrets.yaml.enc > cbci-secrets.yaml
