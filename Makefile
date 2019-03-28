
.ONESHELL:
.SHELL := /usr/bin/bash

VARENV=testenv
VARS="variables/${VARENV}.tfvars"
CURRENT_FOLDER=$(shell basename "$$(pwd)")
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

.DEFAULT_GOAL := help


.PHONY: fmt
fmt: ## terraform format
	@terraform fmt $(args) $(RUN_ARGS)
.PHONY: lint
lint: ## Rewrites config to canonical format
	@terraform fmt -diff=true -check $(args) $(RUN_ARGS)



init: ## Init terraform module
	@terraform init \
		-input=false

plan: init ## Show what terraform thinks it will do
	@terraform plan \
		-lock=true \
		-input=false \
		-refresh=true


plan-destroy: init ## Creates a destruction plan.
	@terraform plan \
		-input=false \
		-refresh=true \
		-destroy

up: apply	## alias of apply 
apply: init ## Have terraform do the things. This will cost money.
	@terraform apply \
		-lock=true \
		-input=false \
		-refresh=true \
		-auto-approve=true 

del: destroy	## alias of destroy
delete: destroy ## alias of destroy
destroy: init ## Destroy the things
	@terraform destroy \
		-lock=true \
		-input=false \
		-refresh=true \
		-force 
	@rm -rf tfplan
	@rm -rf terraform.tfstate.backup


help:
	@printf "\033[32mTerraform-makefile\033[0m\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
