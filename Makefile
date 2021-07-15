# Copyright (C) 2020-2021 Nicolas Lamirault <nicolas.lamirault@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include hack/commons.mk
-include hack/$(CLOUD).$(ENV).mk

# ====================================
# D E V E L O P M E N T
# ====================================

##@ Development

.PHONY: clean
clean: ## Cleanup
	@echo -e "$(OK_COLOR)[$(BANNER)] Cleanup$(NO_COLOR)"
	@find . -name "*.retry"|xargs rm -f
	@rm -fr vendor
	@rm -fr venv

.PHONY: check
check: check-kubectl check-kustomize check-helm check-flux check-conftest check-kubeval check-popeye ## Check requirements

.PHONY: init
init: ## Initialize environment
	@poetry install

.PHONY: doc
doc: ## Generate documentation
	@echo -e "$(OK_COLOR)[$(APP)] Documentation$(NO_COLOR)" >&2
	@. $(PYTHON_VENV)/bin/activate && mkdocs serve

.PHONY: diagrams
diagrams: guard-CLOUD_PROVIDER guard-OUTPUT ## Generate diagrams
	@poetry run python3 diagrams/kubernetes.py --output=$(OUTPUT) --cloud=$(CLOUD_PROVIDER) \
		&& mv *.$(OUTPUT) docs/img \
		&& poetry run python3 diagrams/portefaix.py --output=$(OUTPUT) --cloud=$(CLOUD_PROVIDER) \
		&& mv *.$(OUTPUT) docs/img

.PHONY: validate
validate: ## Execute git-hooks
	@pre-commit run -a

# ====================================
# T E R R A F O R M
# ====================================

##@ Terraform

.PHONY: terraform-init
terraform-init: guard-SERVICE guard-ENV ## Plan infrastructure (SERVICE=xxx ENV=xxx)
	@echo -e "$(OK_COLOR)[$(APP)] Init infrastructure$(NO_COLOR)" >&2
	@cd $(SERVICE)/terraform \
		&& terraform init -upgrade -reconfigure -backend-config=backend-vars/$(ENV).tfvars

.PHONY: terraform-plan
terraform-plan: guard-SERVICE guard-ENV ## Plan infrastructure (SERVICE=xxx ENV=xxx)
	@echo -e "$(OK_COLOR)[$(APP)] Plan infrastructure$(NO_COLOR)" >&2
	@cd $(SERVICE)/terraform \
		&& terraform init -upgrade -reconfigure -backend-config=backend-vars/$(ENV).tfvars \
		&& terraform plan -var-file=tfvars/$(ENV).tfvars

.PHONY: terraform-apply
terraform-apply: guard-SERVICE guard-ENV ## Builds or changes infrastructure (SERVICE=xxx ENV=xxx)
	@echo -e "$(OK_COLOR)[$(APP)] Apply infrastructure$(NO_COLOR)" >&2
	@cd $(SERVICE)/terraform \
		&& terraform init -upgrade -reconfigure -backend-config=backend-vars/$(ENV).tfvars \
		&& terraform apply -var-file=tfvars/$(ENV).tfvars

.PHONY: terraform-destroy
terraform-destroy: guard-SERVICE guard-ENV ## Builds or changes infrastructure (SERVICE=xxx ENV=xxx)
	@echo -e "$(OK_COLOR)[$(APP)] Apply infrastructure$(NO_COLOR)" >&2
	@cd $(SERVICE)/terraform \
		&& terraform init -upgrade -reconfigure -backend-config=backend-vars/$(ENV).tfvars \
		&& terraform destroy -lock-timeout=60s -var-file=tfvars/$(ENV).tfvars

.PHONY: terraform-tflint
terraform-tflint: guard-SERVICE ## Lint Terraform files
	@echo -e "$(OK_COLOR)[$(APP)] Lint Terraform code$(NO_COLOR)" >&2
	@cd $(SERVICE)/terraform \
		&& tflint \
		--enable-rule=terraform_deprecated_interpolation \
		--enable-rule=terraform_deprecated_index \
		--enable-rule=terraform_unused_declarations \
		--enable-rule=terraform_comment_syntax \
		--enable-rule=terraform_documented_outputs \
		--enable-rule=terraform_documented_variables \
		--enable-rule=terraform_typed_variables \
		--enable-rule=terraform_naming_convention \
		--enable-rule=terraform_required_version \
		--enable-rule=terraform_required_providers \
		--enable-rule=terraform_unused_required_providers \
		--enable-rule=terraform_standard_module_structure

.PHONY: terraform-tfsec
terraform-tfsec: guard-SERVICE ## Scan Terraform files
	@echo -e "$(OK_COLOR)[$(APP)] Lint Terraform code$(NO_COLOR)" >&2
	@cd $(SERVICE)/terraform \
		&& tfsec \

.PHONY: terraform-docs
terraform-docs: guard-SERVICE ## Generate documentation
	@echo -e "$(OK_COLOR)[$(APP)] Lint Terraform code$(NO_COLOR)" >&2
	@cd $(SERVICE)/terraform \
		&& terraform-docs markdown . > README.md


# ====================================
# K U B E R N E T E S
# ====================================

##@ Kubernetes

kubernetes-check-context:
	@if [[ "$(KUBE_CONTEXT)" != "$(KUBE_CURRENT_CONTEXT)" ]] ; then \
		echo -e "$(ERROR_COLOR)[KO]$(NO_COLOR) Kubernetes context: $(KUBE_CONTEXT) vs $(KUBE_CURRENT_CONTEXT)"; \
		exit 1; \
	fi

.PHONY: kubernetes-switch
kubernetes-switch: guard-ENV ## Switch Kubernetes context (ENV=xxx)
	@kubectl config use-context $(KUBE_CONTEXT)

.PHONY: kubernetes-secret
kubernetes-secret: guard-NAMESPACE guard-NAME guard-FILE ## Generate a Kubernetes secret file (NAME=xxxx NAMESPACE=xxxx FILE=xxxx)
	@kubectl create secret generic $(NAME) -n $(NAMESPACE) --dry-run=client --from-file=$(FILE) -o yaml

.PHONY: kubernetes-sealed-secret
kubernetes-sealed-secret: guard-FILE ## Sealed secret
	kubeseal --format=yaml --cert=$(CERT) < $(FILE) > $$(dirname $(FILE))/$$(basename -s .yaml $(FILE))-sealed.yaml

.PHONY: kubernetes-credentials
kubernetes-credentials: guard-ENV guard-CLOUD ## Generate credentials (CLOUD=xxxx ENV=xxx)
	make -f hack/$(CLOUD).mk $(CLOUD)-kube-credentials ENV=$(ENV)


# ====================================
# H E L M
# ====================================

##@ Helm

# .PHONY: helm-terraform-repo
# helm-terraform-repo: guard-SERVICE guard-ENV ## Configure Helm repository and chart
# 	@echo -e "$(OK_COLOR)[$(APP)] Helm repository and chart $(SERVICE):$(ENV)$(NO_COLOR)"
# 	@. $(SERVICE)/chart.sh $(SERVICE)/terraform/tfvars/$(ENV).tfvars \
# 		&& helm repo add $${CHART_REPO_NAME} $${CHART_REPO_URL} --force-update \
# 		&& helm repo update

# .PHONY: helm-terraform-values
# helm-terraform-values: guard-SERVICE guard-ENV ## Display Helm values
# 	@echo -e "$(OK_COLOR)[$(APP)] Helm chart values $(SERVICE):$(ENV)$(NO_COLOR)"
# 	@. $(SERVICE)/chart.sh $(SERVICE)/terraform/tfvars/$(ENV).tfvars \
# 		&& helm show values $${CHART_REPO_NAME}/$${CHART_NAME} --version $${CHART_VERSION}

# .PHONY: helm-terraform-template
# helm-terraform-template: guard-SERVICE guard-ENV ## Helm chart rendering
# 	@echo -e "$(OK_COLOR)[$(APP)] Validate Helm chart $(SERVICE):$(ENV)$(NO_COLOR)"
# 	@. $(SERVICE)/chart.sh $(SERVICE)/terraform/tfvars/$(ENV).tfvars \
# 		&& helm template $${CHART_REPO_NAME}/$${CHART_NAME} \
# 		-f $(SERVICE)/terraform/tfvars/values.yaml \
# 		-f $(SERVICE)/terraform/tfvars/$(ENV)-values.yaml

# .PHONY: helm-terraform-policy
# helm-terraform-policy: guard-SERVICE guard-ENV guard-POLICY ## Validate Helm chart
# 	@echo -e "$(OK_COLOR)[$(APP)] Validate Helm chart $(SERVICE):$(ENV)$(NO_COLOR)"
# 	@. $(SERVICE)/chart.sh $(SERVICE)/terraform/tfvars/$(ENV).tfvars \
# 		&& helm template $${CHART_REPO_NAME}/$${CHART_NAME} \
# 		-f $(SERVICE)/terraform/tfvars/values.yaml \
# 		-f $(SERVICE)/terraform/tfvars/$(ENV)-values.yaml | conftest test -p $(POLICY) --all-namespaces -

.PHONY: helm-flux-chart
helm-flux-chart: guard-CHART ## Display Helm chart informations
	@echo -e "$(OK_COLOR)[$(APP)] Helm repository and chart $(CHART)$(NO_COLOR)" >&2
	@DEBUG=true . hack/scripts/chart.sh $(CHART)

.PHONY: helm-flux-repo
helm-flux-repo: guard-CHART ## Configure Helm repository and chart
	@echo -e "$(OK_COLOR)[$(APP)] Helm repository and chart $(CHART)$(NO_COLOR)" >&2
	@DEBUG=$(DEBUG) . hack/scripts/chart.sh $(CHART) \
		&& helm repo add $${CHART_REPO_NAME} $${CHART_REPO_URL} --force-update \
		&& helm repo update

.PHONY: helm-flux-values
helm-flux-values: guard-CHART ## Display Helm values
	@echo -e "$(OK_COLOR)[$(APP)] Helm show values $(CHART)$(NO_COLOR)" >&2
	@DEBUG=$(DEBUG) . hack/scripts/chart.sh $(CHART) \
		&& helm show values $${CHART_REPO_NAME}/$${CHART_NAME} --version $${CHART_VERSION}

.PHONY: helm-flux-custom
helm-flux-show: guard-CHART guard-CLOUD guard-ENV ## Show Helm chart values set for Flux (CHART=xxx ENV=xxx)
	@echo -e "$(OK_COLOR)[$(APP)] Build Helm chart ${CHART}:${ENV}$(NO_COLOR)" >&2
	@DEBUG=$(DEBUG) . hack/scripts/chart.sh $(CHART) \
		&& export TMPFILE=$$(./hack/scripts/flux-helm.sh "$(CHART)" "$(CLOUD)/$(ENV)") \
		&& cat $${TMPFILE}

.PHONY: helm-flux-template
helm-flux-template: guard-CHART guard-CLOUD guard-ENV ## Install Helm chart (CHART=xxx ENV=xxx)
	@echo -e "$(OK_COLOR)[$(APP)] Build Helm chart ${CHART}:${ENV}$(NO_COLOR)" >&2
	@DEBUG=$(DEBUG) . hack/scripts/chart.sh $(CHART) \
		&& export TMPFILE=$$(./hack/scripts/flux-helm.sh "$(CHART)" "$(CLOUD)/$(ENV)") \
		&& helm template --debug $${CHART_NAME} $${CHART_REPO_NAME}/$${CHART_NAME} --namespace $${CHART_NAMESPACE} -f $${TMPFILE}

.PHONY: helm-flux-install
helm-flux-install: guard-CHART guard-CLOUD guard-ENV ## Install Helm chart (CHART=xxx ENV=xxx)
	@echo -e "$(OK_COLOR)[$(APP)] Install Helm chart ${CHART}:${ENV}$(NO_COLOR)" >&2
	@DEBUG=$(DEBUG) . hack/scripts/chart.sh $(CHART) \
		&& export TMPFILE=$$(./hack/scripts/flux-helm.sh "$(CHART)" "$(CLOUD)/$(ENV)") \
		&& echo helm install $${CHART_NAME} $${CHART_REPO_NAME}/$${CHART_NAME} --namespace $${CHART_NAMESPACE} -f $${TMPFILE}


# ====================================
# O P A
# ====================================

##@ Opa

.PHONY: opa-deps
opa-deps: ## Setup OPA dependencies
	@echo -e "$(OK_COLOR)[$(APP)] Install OPA policies $(POLICY)$(NO_COLOR)" >&2
	@conftest pull --policy addons/policies/deprek8ion github.com/swade1987/deprek8ion//policies
	@conftest pull --policy addons/policies/portefaix github.com/portefaix/portefaix-policies?ref=v0.3.0//policy

POHONY: opa-test
opa-test: ## Test policies
	@opa test addons/policies/core

.PHONY: opa-policy
opa-policy-base: guard-CHART guard-ENV guard-POLICY ## Check OPA policies for a Helm chart (CHART=xxx ENV=xxx POLICY=xxx)
	@echo -e "$(OK_COLOR)[$(APP)] Open Policy Agent check policies $(CHART):$(ENV)$(NO_COLOR)" >&2
	@DEBUG=$(DEBUG) . hack/scripts/chart.sh $(CHART) \
		&& export TMPFILE=$$(./hack/scripts/flux-helm.sh $(CHART) $(ENV)) \
		&& helm template $${CHART_NAME} $${CHART_REPO_NAME}/$${CHART_NAME} --namespace $${CHART_NAMESPACE} -f $${TMPFILE} | conftest test --all-namespaces -p $(POLICY) -


# ====================================
# I N S P E C
# ====================================

##@ Inspec

.PHONY: inspec-deps
inspec-deps: ## Install requirements
	@echo -e "$(OK_COLOR)Install requirements$(NO_COLOR)" >&2
	@bundle config set path vendor/bundle --local \
		&& bundle install


# ====================================
# S O P S
# ====================================

##@ Sops

.PHONY: sops-age-key
sops-age-key: guard-CLOUD guard-ENV ## Create an Age key
	@echo -e "$(OK_COLOR)[$(APP)] Create an Age key $(NO_COLOR)" >&2
	@mkdir -p .secrets/$(CLOUD)/$(ENV)/age/ \
		&& age-keygen -o .secrets/$(CLOUD)/$(ENV)/age/age.agekey

.PHONY: sops-age-secret
sops-age-secret: guard-CLOUD guard-ENV ## Create the Kubernetes secret using an AGE key
	@echo -e "$(OK_COLOR)[$(APP)] Create Kubernetes secret for AGE key $(NO_COLOR)" >&2
	@kubectl create secret generic sops-age \
		--namespace=flux-system \
		--from-file=age.agekey=.secrets/$(CLOUD)/$(ENV)/age/age.agekey

.PHONY: sops-pgp-key
sops-pgp-key: guard-CLOUD guard-ENV ## Create a PGP key
	@echo -e "$(OK_COLOR)[$(APP)] Create a PGP key $(NO_COLOR)" >&2
	@./hack/scripts/gpg.sh $(CLOUD) $(ENV)

.PHONY: sops-pgp-secret
sops-pgp-secret: guard-CLOUD guard-ENV ## Create the Kubernetes secret using a PGP key
	@echo -e "$(OK_COLOR)[$(APP)] Create Kubernetes secret for PGP key $(NO_COLOR)" >&2
	@kubectl create secret generic sops-gpg \
		--namespace=flux-system \
		--from-file=sops.asc=.secrets/$(CLOUD)/$(ENV)/gpg/sops.asc

.PHONY: sops-encrypt
sops-encrypt: guard-CLOUD guard-ENV guard-FILE ## Encrypt a Kubernetes secret file (CLOUD=xxx ENV=xxx FILE=xxx)
	@sops --encrypt --encrypted-regex '^(data|stringData)' --in-place --$(SOPS_PROVIDER) $(SOPS_KEY) $(FILE)

.PHONY: sops-encrypt-raw
sops-encrypt-raw: guard-CLOUD guard-ENV guard-FILE ## Encrypt raw file (CLOUD=xxx ENV=xxx FILE=xxx)
	@sops --encrypt --$(SOPS_PROVIDER) $(SOPS_KEY) $(FILE)

.PHONY: sops-decrypt
sops-decrypt: guard-CLOUD guard-ENV guard-FILE ## Decrypt
	@SOPS_AGE_KEY_FILE=.secrets/$(CLOUD)/$(ENV)/age/age.agekey sops --decrypt $(FILE)

# ====================================
# G I T O P S
# ====================================

##@ Gitops

.PHONY: gitops-bootstrap
gitops-bootstrap: guard-ENV guard-CLOUD guard-BRANCH kubernetes-check-context ## Bootstrap Flux v2
	./hack/scripts/bootstrap.sh clusters/$(CLOUD)/$(ENV) $(BRANCH)

.PHONY: release-prepare
release-prepare: guard-VERSION ## Update release label
	./hack/scripts/portefaix-labels.sh kubernetes $(VERSION)
	./hack/scripts/validate.sh clusters kubernetes
