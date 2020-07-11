#!/usr/bin/make -f

SHELL                   := /usr/bin/env bash
REPO_NAMESPACE          ?= synapsestudios
REPO_USERNAME           ?= synapsestudios
REPO_API_URL            ?= https://hub.docker.com/v2
IMAGE_NAME              ?= devops-toolbox
TAG_SUFFIX              ?= $(shell echo "-$(BASE_IMAGE)" | $(SED) 's|:|-|g' | $(SED) 's|/|_|g' 2>/dev/null )
SED                     := $(shell [[ `command -v gsed` ]] && echo gsed || echo sed)
VERSION                 := $(shell git rev-parse --abbrev-ref HEAD | $(SED) 's|release/||g' | $(SED) 's|/|_|g' 2>/dev/null)
VCS_REF                 := $(shell git rev-parse --short HEAD 2>/dev/null || echo "0000000")
BUILD_DATE              := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_OUTPUT            ?= type=registry
BUILD_PROGRESS          ?= auto
MICRO_BADGER_URL        ?=
RELEASES                ?= latest

# Build Args
AZURE_CLI_VERSION       ?= 2.8.0
BASE_IMAGE              ?= alpine:3.12
CIRCLE_CI_CLI_VERSION   ?= 0.1.8599
DOCKER_GID              ?= 1001
DOCKER_GROUP            ?= synapse
DOCKER_UID              ?= 1001
DOCKER_USER             ?= synapse
FLY_VERSION             ?= 6.0.0
GIT_CRYPT_VERSION       ?= master
K6_VERSION              ?= v0.26.2
KIND_VERSION            ?= v0.7.0
KOPS_VERSION            ?= v1.17.0-beta.1
KUBECTL_VERSION         ?= v1.18.0
LEGO_VERSION            ?= 3.8.0
PACKER_VERSION          ?= 1.5.5
SPIN_VERSION            ?= 1.14.0
STARSHIP_VERSION        ?= v0.38.0
TERRAFORM_DOCS_VERSION  ?= v0.9.1
TERRAFORM_LSP_VERSION   ?= 0.0.10
TERRAFORM_VERSION       ?= 0.12.24
TFLINT_VERSION          ?= v0.15.3

# Default target is to build container
.PHONY: default
.SILENT: default
default: latest

# Build the docker image
.PHONY: $(RELEASES)
.SILENT: $(RELEASES)
$(RELEASES):
	docker build \
		--build-arg AZURE_CLI_VERSION=$(AZURE_CLI_VERSION) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg CIRCLE_CI_CLI_VERSION=$(CIRCLE_CI_CLI_VERSION) \
		--build-arg DOCKER_GID=$(DOCKER_GID) \
		--build-arg DOCKER_GROUP=$(DOCKER_GROUP) \
		--build-arg DOCKER_UID=$(DOCKER_UID) \
		--build-arg DOCKER_USER=$(DOCKER_USER) \
		--build-arg FLY_VERSION=$(FLY_VERSION) \
		--build-arg GIT_CRYPT_VERSION=$(GIT_CRYPT_VERSION) \
		--build-arg K6_VERSION=$(K6_VERSION) \
		--build-arg KOPS_VERSION=$(KOPS_VERSION) \
		--build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) \
		--build-arg LEGO_VERSION=$(LEGO_VERSION) \
		--build-arg PACKER_VERSION=$(PACKER_VERSION) \
		--build-arg SPIN_VERSION=$(SPIN_VERSION) \
		--build-arg STARSHIP_VERSION=$(STARSHIP_VERSION) \
		--build-arg TERRAFORM_DOCS_VERSION=$(TERRAFORM_DOCS_VERSION) \
		--build-arg TERRAFORM_LSP_VERSION=$(TERRAFORM_LSP_VERSION) \
		--build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
		--build-arg TFLINT_VERSION=$(TFLINT_VERSION) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VERSION=$(VERSION) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(@) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(@)$(TAG_SUFFIX) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(VCS_REF) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(VCS_REF)$(TAG_SUFFIX) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(VERSION) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(VERSION)$(TAG_SUFFIX) \
		--file Dockerfile .

# List built images
.PHONY: list
.SILENT: list
list:
	docker images $(REPO_NAMESPACE)/$(IMAGE_NAME) --filter "dangling=false"

# Run any tests
.PHONY: test
test:
	docker run -t $(REPO_NAMESPACE)/$(IMAGE_NAME) env | grep VERSION | grep $(VERSION)

# Push images to repo
.PHONY: push
.SILENT: push
push: build
	echo "$$REPO_PASSWORD" | docker login -u "$(REPO_USERNAME)" --password-stdin; \
		docker push  $(REPO_NAMESPACE)/$(IMAGE_NAME):latest; \
		docker push  $(REPO_NAMESPACE)/$(IMAGE_NAME):$(VCS_REF)$(TAG_SUFFIX); \
		docker push  $(REPO_NAMESPACE)/$(IMAGE_NAME):$(VERSION)$(TAG_SUFFIX);

# Update README on registry
.PHONY: push-readme
.SILENT: push-readme
push-readme:
	echo "Authenticating to $(REPO_API_URL)"; \
		token=$$(curl -s -X POST -H "Content-Type: application/json" -d '{"username": "$(REPO_USERNAME)", "password": "'"$$REPO_PASSWORD"'"}' $(REPO_API_URL)/users/login/ | jq -r .token); \
		code=$$(jq -n --arg description "$$(<README.md)" '{"registry":"registry-1.docker.io","full_description": $$description }' | curl -s -o /dev/null  -L -w "%{http_code}" $(REPO_API_URL)/repositories/$(REPO_NAMESPACE)/$(IMAGE_NAME)/ -d @- -X PATCH -H "Content-Type: application/json" -H "Authorization: JWT $$token"); \
		if [ "$$code" != "200" ]; \
		then \
			echo "Failed to update README.md"; \
			exit 1; \
		else \
			echo "Success"; \
		fi;

# Remove existing images
.PHONY: clean
.SILENT: clean
clean:
	docker rmi $$(docker images $(REPO_NAMESPACE)/$(IMAGE_NAME) --format="{{.Repository}}:{{.Tag}}") --force
