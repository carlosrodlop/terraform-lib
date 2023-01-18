MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile
DEBUG			:= true
DIR_SHARED_CB	:= $(MKFILE)/../shared/cb
SHELL 			:= /bin/bash

include $(PARENT_MKFILE)

export KUBECONFIG=$(MKFILE)/../terraform/shared/root/kube.eks.conf.yaml

#DEFAULTS
ROOT 			?= cloudbees/eks

#https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable
.PHONY: check_kubeconfig
check_kubeconfig: ## Check for the required KUBECONFIG environment variable
check_kubeconfig:
#TODO check if KUBECONFIG file exists
ifndef KUBECONFIG
	@echo Warning: KUBECONFIG Environment variable isn\'t defined and it is required for helm\; Example: export KUBECONFIG=exampleProfile
	@exit 1
endif

.PHONY: cb-helm-update
cb-helm-update: ## Install and Update CloudBees Core via Helm. It requires the file .env
cb-helm-update: check_kubeconfig guard-ROOT
	$(call print_title,Update CloudBees Core via Helm)
	source $(ROOT)/.env && \
		cp $(DIR_SHARED_CB)/casc/oc/general/main.yaml.tpl $(DIR_SHARED_CB)/casc/oc/general/main.yaml && \
		yq w -i  $(DIR_SHARED_CB)/casc/oc/general/main.yaml 'unclassified.location.url' "$$CBCI_URL" && \
		yq w -i  $(DIR_SHARED_CB)/casc/oc/general/main.yaml 'unclassified.bundleStorageService.activeBundle.retriever.SCM.scmSource.git.remote' "$$CASC_BUNDLE_REPO" && \
		sed "s/@@HOSTNAME@@/$$DOMAIN/g; s/@@AGENT_NAMESPACE@@/$$AGENT_NA/g; s/@@PLATFORM@@/$$PLATFORM/g" < $(ROOT)/cbci.yaml.tpl > $(ROOT)/cbci.yaml
	source $(ROOT)/.env && \
		kubectl create ns $$CBCI_NS || echo "There is an existing namespace $$CBCI_NS" && \
		kubectl delete configmap oc-casc-bundle -n "$$CBCI_NS" || echo "There is NOT existing configmap oc-casc-bundle in $$CBCI_NS to delete" &&  \
		kubectl create configmap oc-casc-bundle -n "$$CBCI_NS" --from-file=$(DIR_SHARED_CB)/casc/oc/general && \
		kubectl delete secret oc-secrets -n "$$CBCI_NS" || echo "There is NOT existing secret oc-secrets in $$CBCI_NS to delete" &&  \
		kubectl create secret generic oc-secrets -n "$$CBCI_NS" \
			--from-literal=jenkinsPass="$(shell yq r $(DIR_SHARED_CB)/secrets/cbci-secrets.yaml 'jenkinsPass')" \
			--from-literal=githubUser="$(shell yq r $(DIR_SHARED_CB)/secrets/cbci-secrets.yaml 'githubUser')" \
			--from-literal=githubToken="$(shell yq r $(DIR_SHARED_CB)/secrets/cbci-secrets.yaml 'githubToken')" \
			--from-literal=licenseCert="$(shell yq r $(DIR_SHARED_CB)/secrets/cbci-secrets.yaml 'licenseCert')" \
			--from-literal=licenseKey="$(shell yq r $(DIR_SHARED_CB)/secrets/cbci-secrets.yaml 'licenseKey')" && \
		helm repo add cloudbees https://public-charts.artifacts.cloudbees.com/repository/public/ && \
		helm repo update && \
		helm upgrade --install cbci cloudbees/cloudbees-core --namespace "$$CBCI_NS" --version "$$CBCI_VERSION" -f "$(ROOT)/cbci.yaml"

.PHONY: cb-helm-delete
cb-helm-delete: ## Delete CloudBees Core via Helm
cb-helm-delete: check_kubeconfig guard-ROOT
	$(call print_title,Uninstall CloudBees Core via Helm)
	source $(ROOT)/.env && \
		kubectl delete --all pods --grace-period=0 --force --namespace "$$CBCI_NS" && \
		kubectl delete --all pods --grace-period=0 --force --namespace "$$AGENT_NA" && \
		helm uninstall cbci --namespace "$$CBCI_NS" || echo "Relese $$CBCI_NS does not exist" && \
		helm repo remove cloudbees || echo "Repository cloudbees does not exist" && \
		kubectl delete pvc --all --namespace "$$CBCI_NS" && \
		kubectl delete ns "$$AGENT_NA" || echo "There is NOT existing namespace $$AGENT_NA" && \
		kubectl delete ns "$$CBCI_NS" || echo "There is not existing namespace $$CBCI_NS"
