SHELL := /bin/bash
LINUX_SHELL ?=/bin/bash
LINUX_CMD_SHELL ?=/bin/bash -c
ENV_FILE =.env
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
CNT=php
COMPOSE_FILE=docker-compose.yml
SLEEP=2
DEBUG_MAKE_FILE=false


define setup_compose_file
 $(if $(filter none,$(CONFIG_MONOLITHIC)), \
        $(eval COMPOSE_FILE := docker-compose-microservices.yml) \
        $(info Using microservices compose file $(COMPOSE_FILE)), \
    $(if $(filter none,$(CONFIG_BACKEND)), \
        $(eval COMPOSE_FILE := docker-compose-monolithic.yml) \
        $(info Using monolithic compose file $(COMPOSE_FILE)) \
    ))
endef

# Define the check_docker_running function
define check_docker_running
    @if ! docker info > /dev/null 2>&1; then \
        echo "Docker is not running. Please start Docker and try again."; \
        exit 1; \
    fi
endef


define setup_env
    $(call check_docker_running)
	$(shell test ! -f $(1) && echo $(pwd)/assets/compose/$(ENV_FILE) file does not exist && exit)
	$(eval ENV_FILE := $(1))
	$(eval include $(1))
    $(eval export sed 's/=.*//' $(1))
	$(call setup_compose_file)
endef

define env
	$(call setup_env,$(ENV_FILE))
	@echo COMPOSE_FILE=$(COMPOSE_FILE)
endef

include make/basic.mk
include make/cake.mk
include make/nestjs.mk
include make/commands.mk
include make/docker.mk
include make/laravel.mk
#include make/symfony.mk
include make/javascript.mk


commands:
	$(call commands)
.PHONY: commands


### DOCKER COMMANDS ###

build:
	$(call build )
.PHONY: build

down:
	$(call down)
.PHONY: down

### BASIC COMMANDS ###

env:
	$(call env)
.PHONY: env

clean:
	$(call clean_mysql)
.PHONY: clean

codecept:
	$(call codecept)
.PHONY: codecept

console:
	$(call console)
.PHONY: console

composer:
	$(call composer)
.PHONY: composer

dump:
	$(call dump_mysql)
.PHONY: dump

enable:
	$(call enable)
.PHONY: enable

disable:
	$(call disable)
.PHONY: disable

fresh:
	$(call fresh)
.PHONY: fresh

fresh/testdb:
	$(call fresh_testdb)
.PHONY: fresh_testdb

fresh/db:
	$(call fresh_db)
.PHONY: fresh_db


log:
	$(call container_log)
.PHONY: log


import:
	$(call import_mysql)
.PHONY: import




mount:
	$(call mount)
.PHONY: mount

test:
	$(call test)
.PHONY: test

test/filter:
	$(call pest_filter)
.PHONY: test/filter

test/unit:
	$(call phpunit)
.PHONY: test/unit

test/pest:
	$(call pest)
.PHONY: test/pest

test/vitest:
	$(call vitest)
.PHONY: vitest

test/api:
	$(call codecept_api)
.PHONY: test/api


phpunit:
	$(call phpunit)	
.PHONY: phpunit

phpstan:
	$(call phpstan)
.PHONY: phpstan

php-cs-fixer:
	$(call php-cs-fixer)
.PHONY: php-cs-fixer

phpcsfixer:
	$(call php-cs-fixer)
.PHONY: php-cs-fixer

phpdoc:
	$(call phpdoc)	
.PHONY: phpdoc

psalm:
	$(call psalm)
.PHONY: psalm

schema-spy:
	$(call schema_spy)
.PHONY: schema-spy

restart:
		$(call restart)
.PHONY: restart

up:	
	$(call up)
.PHONY: up
