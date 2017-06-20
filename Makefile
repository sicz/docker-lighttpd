################################################################################

BASEIMAGE_NAME		= $(DOCKER_PROJECT)/baseimage-alpine
BASEIMAGE_TAG		= 3.6

################################################################################

DOCKER_PROJECT		?= sicz
DOCKER_NAME		= lighttpd
DOCKER_TAG		= $(BASEIMAGE_TAG)
DOCKER_DESCRIPTION	= A lighttpd web server based on Alpine Linux
DOCKER_PROJECT_URL	= https://www.lighttpd.net

DOCKER_RUN_OPTS		+= -v $(CURDIR)/spec/fixtures/www:/var/www \
			   -v /var/run/docker.sock:/var/run/docker.sock

################################################################################

.PHONY: all build rebuild deploy run up destroy down clean rm start stop restart
.PHONY: status logs shell refresh test clean

all: destroy build deploy logs test
build: docker-build
rebuild: docker-rebuild
deploy run up: docker-deploy
destroy down clean rm: docker-destroy
start: docker-start
stop: docker-stop
restart: docker-stop docker-start
status: docker-status
logs: docker-logs
logs-tail: docker-logs-tail
shell: docker-shell
refresh: docker-refresh
test: docker-test
clean: destroy docker-clean

################################################################################

DOCKER_MK_DIR		?= ../Mk
include $(DOCKER_MK_DIR)/docker.container.mk

################################################################################
