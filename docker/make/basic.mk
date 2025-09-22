define composer
	$(call setup_env,$(ENV_FILE))
	@docker exec -it $(CNT) $(LINUX_CMD_SHELL) "composer $(RUN_ARGS)"
endef 



define test
	$(call setup_env,$(ENV_FILE))
	@echo "Select an option:"
	@echo "1) vitest"
	@echo "2) pest"
	@echo "3) pest filter"
	@echo "4) phpunit"
	@echo "5) codecept"
	@read -p "Enter your choice applicable to the current project [1-5]: " choice; \
	case $$choice in \
		1) make test/vitest ;; \
		2) make test/pest ;; \
		3) make test/pest_filter ;; \
		4) make test/phpunit ;; \
		5) make test/codecept_api ;; \
		*) echo "Invalid option"; exit 1 ;; \
	esac
endef

define fresh
	$(call setup_env,$(ENV_FILE))
	@echo "Select an option:"
	@echo "1) test db"
	@echo "2) main db"
	@read -p "Enter your choice applicable to the current project [1-5]: " choice; \
	case $$choice in \
		1) make fresh/testdb ;; \
		2) make fresh/db ;; \
		*) echo "Invalid option"; exit 1 ;; \
	esac
endef

define fresh_db
	$(call setup_env,$(ENV_FILE))
	make artisan "migrate:fresh --database=mysql --seed"
endef

define fresh_testdb
	$(call setup_env,$(ENV_FILE))
	make artisan "migrate:fresh --database=mysql_test"
endef

define composer
	$(call setup_env,$(ENV_FILE))
	docker exec -it $(CNT) $(LINUX_CMD_SHELL) "/usr/bin/composer $(RUN_ARGS)"
endef


define phpstan
	$(call setup_env,$(ENV_FILE))
	docker exec -it $(CNT) $(LINUX_CMD_SHELL) "vendor/bin/phpstan analyse $(SRC_FOLDER) --level=5"
endef


define phpunit
	$(call setup_env,$(ENV_FILE))
	docker exec -it $(CNT) $(LINUX_CMD_SHELL) "vendor/bin/phpunit $(RUN_ARGS)"
endef



define codecept_api
	$(call setup_env,$(ENV_FILE))
	docker exec -it $(CNT) $(LINUX_CMD_SHELL) "vendor/bin/codecept run api $(RUN_ARGS)"
endef

define php-cs-fixer
	$(call setup_env,$(ENV_FILE))
	docker exec -it $(CNT) $(LINUX_CMD_SHELL) "vendor/bin/php-cs-fixer fix $(SRC_FOLDER) --rules=@PSR12"
endef

define phpdoc
	$(call setup_env,$(ENV_FILE))
	echo "Generating PHPDoc in $(PROJECT_PATH)/docs/phpdoc ..."
	docker exec -it $(CNT) $(LINUX_CMD_SHELL) "php phpdoc.phar -d app -t docs/phpdoc"
	open ${PROJECT_PATH}/docs/phpdoc/index.html
endef

define psalm
	$(call setup_env,$(ENV_FILE))
	docker exec -it $(CNT) $(LINUX_CMD_SHELL) "vendor/bin/psalm --show-info=true --threads=4"
endef