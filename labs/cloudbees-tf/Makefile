MKFILE_CB      	:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(MKFILE_CB)/../../Makefile
DEBUG			:= true
DIR_ROOT_CB		:= $(MKFILE_CB)/root
#DEFAULTS
ROOT 			?= eks

include $(PARENT_MKFILE)

export TF_LOG_PATH=$(DIR_ROOT_CB)/terraform.log
export TF_VAR_scm_bundle_store = "https://github.com/carlosrodlop/cb-casc-controllers"

.PHONY: tf_init
tf_init: ## Init CloudBees root cluster passed as parameter.  Usage: ROOT=cb-ci make tf_init (Defaults to eks)
tf_init: guard-ROOT check_aws_profile
	$(call print_title,Init $(ROOT) Cluster)
	@terraform -chdir=$(DIR_ROOT_CB)/$(ROOT) fmt
	@terraform -chdir=$(DIR_ROOT_CB)/$(ROOT) init
	@terraform -chdir=$(DIR_ROOT_CB)/$(ROOT) validate

.PHONY: tf_init_s3
tf_init_s3: ## Init CloudBees root cluster passed as parameter. Including Backed initicialization. Usage: ROOT=cb-ci make tf_init  (Defaults to eks)
tf_init_s3: guard-ROOT check_aws_profile
	$(call print_title,Init $(ROOT) Cluster)
	@terraform -chdir=$(DIR_ROOT_CB)/$(ROOT) fmt
	@terraform -chdir=$(DIR_ROOT_CB)/$(ROOT) init \
		-backend-config="bucket=$(shell terraform -chdir=$(ROOT_SHARED) output --raw backend_name)" \
		-backend-config="region=$(shell terraform -chdir=$(ROOT_SHARED) output --raw aws_region)" \
		-backend-config="dynamodb_table=$(shell terraform -chdir=$(ROOT_SHARED) output --raw dynamo_table_lock_name)"
		-backend-config="key=state/$(ROOT).tfstate"
		-backend-config="kms_key_id=alias/$(ROOT)-bucket-key"
	@terraform -chdir=$(DIR_ROOT_CB)/$(ROOT) validate

.PHONY: tf_apply
tf_apply: ## Apply CloudBees root cluster passed as parameter. Usage: ROOT=cb-ci make tf_apply (Defaults to eks)
tf_apply: guard-ROOT check_aws_profile
	@rm -rf $(TF_LOG_PATH)
	$(call print_title,Apply $(ROOT) Cluster) |tee -a $(TF_LOG_PATH)
	@terraform -chdir="$(DIR_ROOT_CB)/$(ROOT)" plan -out="$(DIR_ROOT_CB)/$(ROOT)/$(ROOT).plan" -var-file="$(ENV_EKS_LABS)/shared.tfvars" -input=false
	@terraform -chdir="$(DIR_ROOT_CB)/$(ROOT)" apply "$(DIR_ROOT_CB)/$(ROOT)/$(ROOT).plan"

.PHONY: tf_destroy
tf_destroy: ## Destroy CloudBees root cluster passed as parameter. Usage: ROOT=ci-alpha make tf_destroy
tf_destroy: guard-ROOT check_aws_profile
	$(call print_title,Destroy $(ROOT) Cluster) |tee -a $(TF_LOG_PATH)
	@rm -rf $(TF_LOG_PATH)
ifeq ($(ROOT),eks)
	@terraform -chdir="$(DIR_ROOT_CB)/$(ROOT)" destroy -target=module.eks_blueprints_kubernetes_addons -var-file="$(ENV_EKS_LABS)/shared.tfvars"
	@terraform -chdir="$(DIR_ROOT_CB)/$(ROOT)" destroy -target=module.eks_blueprints -var-file="$(ENV_EKS_LABS)/shared.tfvars"
	@terraform -chdir="$(DIR_ROOT_CB)/$(ROOT)" destroy -target=module.vpc -var-file="$(ENV_EKS_LABS)/shared.tfvars"
	@terraform -chdir="$(DIR_ROOT_CB)/$(ROOT)" destroy -var-file="$(ENV_EKS_LABS)/shared.tfvars"
else ifeq ($(ROOT),eks-r)
	@terraform -chdir="$(DIR_ROOT_CB)/$(ROOT)" destroy -var-file="$(ENV_EKS_LABS)/shared.tfvars"
endif

.PHONY: sops-encription-cb-tf
sops-encription-cb-tf: ## Encript file with SOPS. Upload to GitHub
sops-encription-cb-tf:
	$(call print_title,Encrypting via SOPS)
	@cd $(MKFILE_CB) && SOPS_AGE_RECIPIENTS=$(ENC_KEY) sops -e kube.eks.conf.yaml > kube.eks.conf.yaml.enc

.PHONY: sops-decription-cb-tf
sops-decription-cb-tf: ## Decript file with SOPS. Include them in .gitignore
sops-decription-cb-tf:
	$(call print_title,Decrypting via SOPS)
	@cd $(MKFILE_CB) && SOPS_AGE_KEY=$(DEC_KEY) sops -d kube.eks.conf.enc > kube.eks.conf
