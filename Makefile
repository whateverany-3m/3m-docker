DOCKER_COMPOSE_RUN := docker-compose run --rm
BUILD ?= 0
VERSION := 0.0.0
TARGET_SEMANTIC_VERSION := $(TARGET_VERSION)
TARGET_SEMANTIC_RC := $(TARGET_SEMANTIC_VERSION)-rc.$(TARGET_BUILD)
ENVFILE := .env

preaction: .env env-TARGET_RESISTRY env-TARGET_REGISTRY_TOKEN env-TARGET_REGISTRY_USER
	$(DOCKER_COMPOSE_RUN) 3m make _login
.PHONY: preaction

runaction: .env env-SOURCE_GROUP env-SOURCE_IMAGE env-SOURCE_RESISTRY env-SOURCE_VERSION env-TARGET_GROUP env-TARGET_IMAGE env-TARGET_RESISTRY env-TARGET_SEMANTIC_RC env-TARGET_SEMANTIC_VERSION
	$(DOCKER_COMPOSE_RUN) 3m make _build
	$(DOCKER_COMPOSE_RUN) 3m make _publish
.PHONY: .runaction

postaction: .env env-TARGET_RESISTRY
	$(DOCKER_COMPOSE_RUN) 3m make _logout
.PHONY: postaction

_login:
	docker login --username ${TARGET_REGISTRY_USER} --password "${TARGET_REGISTRY_TOKEN}"  "${TARGET_REGISTRY}"
.PHONY: _login

_build:
	docker build \
		--no-cache \
	  --build-arg SOURCE_GROUP=$(SOURCE_GROUP) \
	  --build-arg SOURCE_REGISTRY=$(SOURCE_REGISTRY) \
	  --build-arg SOURCE_IMAGE=$(SOURCE_IMAGE) \
	  --build-arg SOURCE_VERSION=$(SOURCE_VERSION) \
	  --tag $(TARGET_REGISTRY)$(TARGET_GROUP)$(TARGET_IMAGE):$(TARGET_SEMANTIC_RC) \
	  --tag $(TARGET_REGISTRY)$(TARGET_GROUP)$(TARGET_IMAGE):$(TARGET_SEMANTIC_VERSION) \
	  --file Dockerfile  \
	  .
.PHONY: _build

_publish:
	docker images
	docker push $(TARGET_REGISTRY)$(TARGET_GROUP)$(TARGET_IMAGE):$(TARGET_SEMANTIC_RC)
	docker push $(TARGET_REGISTRY)$(TARGET_GROUP)$(TARGET_IMAGE):$(TARGET_SEMANTIC_VERSION)
.PHONY: _publish

_logout: .env env-TARGET_RESISTRY
	docker logout "${TARGET_REGISTRY}"
.PHONY: _logout

shell: .env env-DOCKER_COMPOSE_RUN
	$(DOCKER_COMPOSE_RUN) 3m /bin/sh
.PHONY: shell

shell-root: .env env-DOCKER_COMPOSE_RUN
	$(DOCKER_COMPOSE_RUN) -u root 3m /bin/sh
.PHONY: shell-root

.env: env-ENVFILE
	echo $(ENVFILE)

env-%:
	echo "INFO: Check if $* is not empty"

