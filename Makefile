MKFILE 			:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
#PARENT_MKFILE   := $(HOME)/.Makefile # docker
PARENT_MKFILE   := $(MKFILE)/../carlosrodlop/Makefile # local
DEBUG			:= true
CB_EKS_LABS		:= $(MKFILE)/shared/cb/secrets

include $(PARENT_MKFILE)

# .PHONY: sops-encription
# sops-encription: ## Encript file with SOPS. Upload to GitHub
# sops-encription:
# 	$(call print_title,Encrypting via SOPS)
# 	@cd $(CB_EKS_LABS)/secrets && SOPS_AGE_RECIPIENTS=$(ENC_KEY) sops -e cbci-secrets.yaml > cbci-secrets.yaml.enc

# .PHONY: sops-decription
# sops-decription: ## Decript file with SOPS. Include them in .gitignore
# sops-decription:
# 	$(call print_title,Decrypting via SOPS)
# 	@cd $(CB_EKS_LABS)/secrets && SOPS_AGE_KEY=$(DEC_KEY) sops -d cbci-secrets.yaml.enc > cbci-secrets.yaml
