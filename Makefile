# tf-tools developer tasks.
# Override the binary if you use OpenTofu: `make TF=tofu validate`
TF ?= terraform

# Every directory containing Terraform files (modules, examples, environments),
# minus those opted out with a `.validate-skip` marker (experimental modules).
TF_DIRS = $(shell find modules environments -type f -name '*.tf' \
	-exec dirname {} \; | sort -u | while read d; do \
	  [ -f "$$d/.validate-skip" ] || echo "$$d"; done)

# Module directories that carry a `terraform test` suite.
TEST_DIRS = $(shell find modules -type d -name tests -exec dirname {} \; | sort -u)

.PHONY: help fmt fmt-check validate test lint docs catalog catalog-check clean new-module

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

fmt: ## Format all Terraform files in place
	$(TF) fmt -recursive

fmt-check: ## Check formatting (CI-friendly, no writes)
	$(TF) fmt -check -recursive

validate: ## Init (no backend) + validate every module and example
	@set -e; for d in $(TF_DIRS); do \
	  echo "==> validate $$d"; \
	  ( cd "$$d" && $(TF) init -backend=false -input=false -no-color >/dev/null && \
	    $(TF) validate -no-color ); \
	done

test: ## Run every module's terraform test suite (mocked providers, no credentials)
	@set -e; for d in $(TEST_DIRS); do \
	  echo "==> test $$d"; \
	  ( cd "$$d" && $(TF) init -backend=false -input=false -no-color >/dev/null && \
	    $(TF) test -no-color ); \
	done

lint: ## Run tflint across the repo
	tflint --init
	tflint --recursive

docs: ## Regenerate module README tables via terraform-docs
	@command -v terraform-docs >/dev/null 2>&1 || { echo "terraform-docs not installed"; exit 1; }
	@for d in $$(find modules -mindepth 1 -name versions.tf -exec dirname {} \;); do \
	  echo "==> docs $$d"; \
	  terraform-docs markdown table --output-file README.md --output-mode inject "$$d"; \
	done

catalog: ## Regenerate the README module catalog from each module's metadata.yaml
	python3 scripts/gen_catalog.py

catalog-check: ## Verify the README module catalog is up to date (CI-friendly)
	python3 scripts/gen_catalog.py --check

clean: ## Remove local .terraform dirs and state
	find . -type d -name ".terraform" -prune -exec rm -rf {} +
	find . -type f -name "*.tfstate*" -delete

new-module: ## Scaffold a new module: make new-module DIR=aws/sns
	@test -n "$(DIR)" || { echo "usage: make new-module DIR=<provider>/<name>"; exit 1; }
	@test ! -d "modules/$(DIR)" || { echo "modules/$(DIR) already exists"; exit 1; }
	cp -r modules/_template "modules/$(DIR)"
	@echo "Created modules/$(DIR) — edit the .tf files and README, then 'make docs'."
