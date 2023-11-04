MKFILE := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile

include $(PARENT_MKFILE)

TDEBUG			:= $(shell echo $(call getEnvProperty,TDEBUG))
AUTOPROVE	    := $(shell echo $(call getEnvProperty,AUTOPROVE))
BACKEND         ?= $(shell echo $(call getEnvProperty,BACKEND))
ROOT 			?= $(shell echo $(call getEnvProperty,TARGET_ROOT))
ROOT_PATH 		?= $(shell echo $(call getEnvProperty,ROOT_PATH))
ROOT_SHARED 	:= $(MKFILE)/$(ROOT_PATH)
AWS_RESOURCES  	:= $(shell echo $(call getEnvProperty,AWS_RESOURCES))
K8S_RESOURCES  	:= $(shell echo $(call getEnvProperty,K8S_RESOURCES))
BPV 			:= $(shell echo $(call getEnvProperty,BPV))
BPV_CURRENT     := $(shell grep -e aws-eks-addons-v $(ROOT_SHARED)/$(K8S_RESOURCES)/main.tf)
TF_INIT_OPTS 	:= $(shell echo $(call getEnvProperty,TF_INIT_OPTS))
ENV_SHARED		:= $(MKFILE)/env
TIMESTAMP		:= $(shell date +%Y%m%d%H%M)

export TF_LOG_PATH=terraform.log

ifeq ($(TDEBUG),true)
	export TF_LOG=DEBUG
endif

.PHONY: check_vars
check_vars: ## Check existing values in .env file
check_vars: check_envfile
	@#printenv | grep -e PAGER -e HOME
	@echo "ROOT: $(ROOT_PATH)/$(ROOT)"
	@echo "AWS_PROFILE: $$AWS_PROFILE"
	@echo "BACKEND: $(BACKEND)"
	@echo "AUTOPROVE: $(AUTOPROVE)"
	@echo -n "Are you sure? [yes/No] " && read ans && [ $${ans:-No} = yes ]

#https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html
.PHONY: check_aws_env
check_aws_env: ## Check for the required environment variables
check_aws_env:
	$(call exitsEnvVariable,AWS_PROFILE,export AWS_PROFILE=example-profile)
	$(call exitsEnvVariable,AWS_DEFAULT_REGION,export AWS_DEFAULT_REGION=us-east-1)

.PHONY: tf_fmtval
tf_fmtval: ## Format and Validate Terraform root passing as parameter. It can accept a remote BACKEND (default to false). Usage: [ROOT=eks][BACKEND=true] make tf_init
tf_fmtval: guard-ROOT
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) fmt
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) validate

.PHONY: tf_init
tf_init: ## Init Terraform root passing as parameter. It can accept a remote BACKEND (default to false). Usage: [ROOT=eks][BACKEND=true] make tf_init
tf_init: guard-ROOT guard-BACKEND check_vars
	$(call print_title,Init $(ROOT_SHARED)/$(ROOT) resources)
ifeq ($(BACKEND),true) #IMPORTANT: It requires backend.tf file in the root folder
	@echo -n "Is there a backend.tf inside $(ROOT)? [yes/No] " && read ans && [ $${ans:-No} = yes ]
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) init $(TF_INIT_OPTS) \
		-backend-config="bucket=$(shell echo $(call getTFValue,$(ROOT_SHARED)/state-bucket,bucket_name))" \
		-backend-config="region=$(shell echo $(call getTFValue,$(ROOT_SHARED)/state-bucket,aws_region))" \
		-backend-config="dynamodb_table=$(shell echo $(call getTFValue,$(ROOT_SHARED)/state-bucket,dynamo_table_lock_name))" \
		-backend-config="key=state/$(ROOT).tfstate" \
		-backend-config="encrypt=true"
else
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) init $(TF_INIT_OPTS)
endif

.PHONY: tf_apply
tf_apply: ## Apply Terraform root passing as parameter (ROOT). Usage: [ROOT=eks-bp-v4] make tf_apply
tf_apply: check_aws_env guard-ROOT check_vars tf_fmtval
	@rm -rf $(TF_LOG_PATH)
	$(call print_title,Apply $(ROOT_SHARED)/$(ROOT) resources) | tee -a $(TF_LOG_PATH)
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) plan -out="$(TIMESTAMP)-$(ROOT).plan" -var-file="$(ENV_SHARED)/shared.tfvars"
ifeq ($(AUTOPROVE),true) # NOTE: Passing plan file does not require to pass var-file
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) apply "$(TIMESTAMP)-$(ROOT).plan"
else
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) apply -var-file="$(ENV_SHARED)/shared.tfvars"
endif
	@terraform -chdir=$(ROOT_SHARED)/$(ROOT) output > $(ROOT_SHARED)/$(ROOT)/$(ROOT).output

.PHONY: tf_destroy
tf_destroy: ## Destroy Terraform root passing as parameter (ROOT, default to eks-bp-v4). Usage: ROOT=eks-bp-v4 make tf_destroy
tf_destroy: guard-ROOT check_aws_env check_vars tf_fmtval
	$(call print_title,Destroy $(ROOT_SHARED)/$(ROOT) Cluster) | tee -a $(TF_LOG_PATH)
	rm -rf $(TF_LOG_PATH)
ifeq ($(ROOT),$(K8S_RESOURCES))
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -target=module.eks_addons -var-file="$(ENV_SHARED)/shared.tfvars"
else ifeq ($(ROOT),$(AWS_RESOURCES))
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -target=module.eks -var-file="$(ENV_SHARED)/shared.tfvars"
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -target=module.bastion -var-file="$(ENV_SHARED)/shared.tfvars"
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -target=module.vpc -var-file="$(ENV_SHARED)/shared.tfvars"
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -var-file="$(ENV_SHARED)/shared.tfvars"
else
	terraform -chdir="$(ROOT_SHARED)/$(ROOT)" destroy -var-file="$(ENV_SHARED)/shared.tfvars"
endif

.PHONY: tf_action
tf_action: ## Generic Terraform Action. Usage: [ROOT=eks-bp-v4] [ACTION="status list"] make tf_action
tf_action: check_aws_env guard-ROOT guard-ACTION check_vars print_vars
	@rm -rf $(TF_LOG_PATH)
	terraform -chdir=$(ROOT_SHARED)/$(ROOT) $(ACTION)

.PHONY: tf_files_plans_wipeout
tf_files_wipeout: ## Wipeout TF files plans. Usage: [ROOT=eks-bp-v4] make tf_files_plans_wipeout
tf_files_wipeout: guard-ROOT
	@echo -n "Are you sure you want to wipeout $(ROOT_PATH)/$(ROOT)? [yes/No] " && read ans && [ $${ans:-No} = yes ]
	rm -rf $(ROOT_SHARED)/$(ROOT).terraform/ || echo "No .terraform folder found"
	rm -f $(ROOT_SHARED)/$(ROOT)/*.plan || echo "No terraform plan files found"
	rm -rf $(ROOT_SHARED)/$(ROOT)/.terraform.lock.hcl || echo "No .terraform.lock.hcl file found"
	rm -rf $(ROOT_SHARED)/$(ROOT)/terraform.tfstate || echo "No .terraform.tfstate file found"
