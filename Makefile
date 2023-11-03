MKFILEDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile

include $(PARENT_MKFILE)

.PHONY: run
run: ## Run terraform-lib within a docker container
run:
	docker run -it --name $(shell echo swissknife.ubuntu.m1 | cut -d ":" -f 1)_$(shell echo $$RANDOM) \
		--env-file=.docker.env \
		-v $(MKFILEDIR):/home/swiss-user/terraform-lib -v $(HOME)/.aws:/home/swiss-user/.aws \
		carlosrodlop/swissknife.ubuntu.m1
