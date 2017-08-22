### BASE_IMAGE #################################################################

BASE_IMAGE_NAME		?= $(DOCKER_PROJECT)/baseimage-alpine
BASE_IMAGE_TAG		?= 3.6

### DOCKER_IMAGE ###############################################################

DOCKER_PROJECT		?= sicz
DOCKER_PROJECT_DESC	= A lighttpd web server based on Alpine Linux
DOCKER_PROJECT_URL	= https://www.lighttpd.net

DOCKER_NAME		?= lighttpd
DOCKER_IMAGE_TAG	?= $(BASE_IMAGE_TAG)
DOCKER_IMAGE_TAGS	?= latest
DOCKER_IMAGE_DEPENDENCIES += $(SIMPLE_CA_IMAGE)

### DOCKER_VERSIONS ###########################################################

DOCKER_VERSIONS		?= latest devel

### BUILD ######################################################################

# Allows a change of the build/restore targets to the docker-tag if
# the development version is the same as the production version
DOCKER_BUILD_TARGET	?= docker-build
DOCKER_REBUILD_TARGET	?= docker-rebuild

### DOCKER_EXECUTOR ############################################################

# Use Docker Compose executor
DOCKER_EXECUTOR		?= compose

# Docker Compose variables
COMPOSE_VARS		+= SERVER_CRT_HOST \
			   SIMPLE_CA_IMAGE

# Subject aletrnative name in certificate
SERVER_CRT_HOST		+= lighttpd.local

### SIMPLE_CA ##################################################################

# Simple CA image
SIMPLE_CA_IMAGE_NAME	?= sicz/simple-ca
SIMPLE_CA_IMAGE_TAG	?= latest
SIMPLE_CA_IMAGE		?= $(SIMPLE_CA_IMAGE_NAME):$(SIMPLE_CA_IMAGE_TAG)

# Simple CA service name in Docker Compose file
SIMPLE_CA_SERVICE_NAME	?= $(shell echo $(SIMPLE_CA_IMAGE_NAME) | sed -E -e "s|^.*/||" -e "s/[^[:alnum:]_]+/_/g")

# Simple CA container name
# Docker container name
ifeq ($(DOCKER_EXECUTOR),container)
SIMPLE_CA_CONTAINER_NAME ?= $(DOCKER_EXECUTOR_ID)_$(SIMPLE_CA_SERVICE_NAME)
else ifeq ($(DOCKER_EXECUTOR),compose)
SIMPLE_CA_CONTAINER_NAME ?= $(DOCKER_EXECUTOR_ID)_$(SIMPLE_CA_SERVICE_NAME)_1
else ifeq ($(DOCKER_EXECUTOR),stack)
# TODO: Docker Swarm Stack executor
SIMPLE_CA_CONTAINER_NAME ?= $(DOCKER_EXECUTOR_ID)_$(SIMPLE_CA_SERVICE_NAME)_1
else
$(error Unknown Docker executor "$(DOCKER_EXECUTOR)")
endif

### MAKE_VARS ##################################################################

MAKE_VARS		?= GITHUB_MAKE_VARS \
			   BASE_IMAGE_MAKE_VARS \
			   DOCKER_IMAGE_MAKE_VARS \
			   BUILD_MAKE_VARS \
			   BUILD_TARGETS_MAKE_VARS \
			   EXECUTOR_MAKE_VARS \
			   CONFIG_MAKE_VARS \
			   SHELL_MAKE_VARS \
			   DOCKER_REGISTRY_MAKE_VARS \
			   DOCKER_VERSION_MAKE_VARS


define BUILD_TARGETS_MAKE_VARS
DOCKER_BUILD_TARGET:	$(DOCKER_BUILD_TARGET)
DOCKER_REBUILD_TARGET:	$(DOCKER_REBUILD_TARGET)
endef
export BUILD_TARGETS_MAKE_VARS

define CONFIG_MAKE_VARS
SIMPLE_CA_IMAGE_NAME:	$(SIMPLE_CA_IMAGE_NAME)
SIMPLE_CA_IMAGE_TAG:	$(SIMPLE_CA_IMAGE_TAG)
SIMPLE_CA_IMAGE:	$(SIMPLE_CA_IMAGE)

SERVER_CRT_HOST:	$(SERVER_CRT_HOST)
endef
export CONFIG_MAKE_VARS

### DOCKER_VERSION_TARGETS #####################################################

DOCKER_ALL_VERSIONS_TARGETS ?= build rebuild ci clean

### MAKE_TARGETS #############################################################

# Build and test image
.PHONY: all ci
all: build deploy logs test
ci:  all destroy

# Display make variables
.PHONY: makevars vars
makevars vars: display-makevars

### BUILD_TARGETS ##############################################################

# Build Docker image with cached layers
.PHONY: build
build: $(DOCKER_BUILD_TARGET)
	@true

# Build Docker image without cached layers
.PHONY: rebuild
rebuild: $(DOCKER_REBUILD_TARGET)
	@true

### EXECUTOR_TARGETS ###########################################################

# Display Docker COmpose/Swarm configuration file
.PHONY: config-file
config-file: display-config-file

# Destroy containers and then start fresh ones
.PHONY: deploy run up
deploy run up:
	@set -e; \
	$(MAKE) destroy start

# Create containers
.PHONY: create
create: display-executor-config secrets docker-create .docker-$(DOCKER_EXECUTOR)-secrets
	@true

.docker-$(DOCKER_EXECUTOR)-secrets:
	@$(ECHO) "Copying secrets to container $(CONTAINER_NAME)"
	@docker cp secrets/ca_crt.pem  	$(CONTAINER_NAME):/etc/ssl/certs
	@docker cp secrets/ca_user.name	$(CONTAINER_NAME):/etc/ssl/private
	@docker cp secrets/ca_user.pwd	$(CONTAINER_NAME):/etc/ssl/private
	@$(ECHO) "Copying spec/fixtures/www/index.html to container $(SIMPLE_CA_CONTAINER_NAME)"
	@docker cp $(TEST_DIR)/spec/fixtures/www/index.html $(CONTAINER_NAME):/var/www
	@$(ECHO) "Copying secrets to container $(SIMPLE_CA_CONTAINER_NAME)"
	@@docker cp secrets $(SIMPLE_CA_CONTAINER_NAME):/var/lib/simple-ca
	@$(ECHO) $(CONTAINER_NAME) > $@

# Start containers
.PHONY: start
start: create docker-start

# List running containers
.PHONY: ps
ps: docker-ps

# Display containers logs
.PHONY: logs
logs: docker-logs

# Follow containers logs
.PHONY: logs-tail tail
logs-tail tail: docker-logs-tail

# Run shell in the container
.PHONY: shell sh
shell sh: start docker-shell

# Run tests for current executor configuration
.PHONY: test
test: start docker-test

# Run shell in test container
.PHONY: test-shell tsh
test-shell tsh:
	@$(MAKE) test TEST_CMD=/bin/bash

# Stop containers
.PHONY: stop
stop: docker-stop

# Restart containers
.PHONY: restart
restart: stop start

# Delete containers
.PHONY: destroy down rm
destroy down rm: docker-destroy

# Clean project
.PHONY: clean
clean: docker-clean clean-secrets

### SIMPLE_CA_TARGETS ##########################################################

# Create Simple CA secrets
.PHONY: secrets
secrets: secrets/ca_user.pwd
	@true

secrets/ca_user.pwd:
	@$(ECHO) "Starting container $(SIMPLE_CA_CONTAINER_NAME) with command \"secrets\""
	@docker run --interactive --tty --name=$(SIMPLE_CA_CONTAINER_NAME) $(SIMPLE_CA_IMAGE) secrets
	@$(ECHO) "Copying secrets from container $(SIMPLE_CA_CONTAINER_NAME)"
	@docker cp $(SIMPLE_CA_CONTAINER_NAME):/var/lib/simple-ca/secrets .
	@$(ECHO) "Destroying container $(SIMPLE_CA_CONTAINER_NAME)"
	@docker rm --force $(SIMPLE_CA_CONTAINER_NAME) > /dev/null

# Clean Simple CA secrets
.PHONY: clean-secrets
clean-secrets:
	@SECRET_FILES=$$(ls secrets/*.pem secrets/*.pwd secrets/*.name 2> /dev/null | tr '\n' ' ' || true); \
	 if [ -n "$${SECRET_FILES}" ]; then \
		$(ECHO) "Removing secrets: $${SECRET_FILES}"; \
		chmod u+w $${SECRET_FILES}; \
		rm -f $${SECRET_FILES}; \
	 fi

### MK_DOCKER_IMAGE ############################################################

PROJECT_DIR		?= $(CURDIR)
MK_DIR			?= $(PROJECT_DIR)/../Mk
include $(MK_DIR)/docker.image.mk

################################################################################
