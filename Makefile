################################################################################

BASEIMAGE_NAME		= $(DOCKER_PROJECT)/baseimage-alpine
BASEIMAGE_TAG		= 3.6

################################################################################

DOCKER_PROJECT		?= sicz
DOCKER_NAME		= lighttpd
DOCKER_TAG		= $(BASEIMAGE_TAG)
DOCKER_TAGS		?= latest
DOCKER_DESCRIPTION	= A lighttpd web server based on Alpine Linux
DOCKER_PROJECT_URL	= https://www.lighttpd.net

DOCKER_RUN_OPTS		+= -v /var/run/docker.sock:/var/run/docker.sock

DOCKER_SUBDIR		+= devel

################################################################################

.PHONY: all build rebuild deploy run up destroy down rm start stop restart
.PHONY: status logs shell refresh test clean clean-all

all: destroy build deploy logs test
build: docker-build
rebuild: docker-rebuild
deploy run up: docker-deploy
destroy down rm: docker-destroy
start: docker-start
stop: docker-stop
restart: docker-stop docker-start
status: docker-status
logs: docker-logs
logs-tail: docker-logs-tail
shell: docker-shell
refresh: docker-refresh
test:  spec-fixtures docker-test
clean: destroy docker-clean
clean-all:
	@for SUBDIR in . $(DOCKER_SUBDIR); do \
		cd $(abspath $(DOCKER_HOME_DIR))/$${SUBDIR}; \
		$(MAKE) clean; \
	done

################################################################################

.PHONY:  spec-fixtures
spec-fixtures: docker-start
	@touch $(DOCKER_CONTAINER_ID); \
	DOCKER_CONTAINER_ID="$$(cat $(DOCKER_CONTAINER_ID))"; \
	if [ -n "$${DOCKER_CONTAINER_ID}" ]; then \
		docker cp $(DOCKER_TEST_DIR)/spec/fixtures/www $${DOCKER_CONTAINER_ID}:/var; \
	fi

################################################################################

DOCKER_HOME_DIR		?= .
DOCKER_MK_DIR		?= $(DOCKER_HOME_DIR)/../Mk
include $(DOCKER_MK_DIR)/docker.container.mk

################################################################################
