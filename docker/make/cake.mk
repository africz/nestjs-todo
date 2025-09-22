cake:
	$(call cake)
.PHONY : cake



define cake
	$(call setup_env,$(ENV_FILE))
	$(call echo_env)
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(eval ARG3 := $(word 3, $(ARGS)))
	$(call cake_exec,$(ARG1),$(ARG2),$(ARG3))
endef


define cake_exec
	$(call setup_env,$(ENV_FILE))
	@if [ "$(1)" = "help" ]; then \
		$(call cake_exec_help); \
	else \
		echo "Executing $(1) $(2) $(3)"; \
			START_TIME=$$(date +%s); \
				docker exec -it $(CNT) $(LINUX_CMD_SHELL) "bin/cake $(1) $(2) $(3)"; \
			END_TIME=$$(date +%s); \
		echo "Execution time: $$((END_TIME - START_TIME)) seconds"; \
fi

endef

define cake_exec_help
echo "Available cake options:" && \
echo "$(COUNTRY_CODES)"; \
echo "make cake" && \
echo "make cake [command]" && \
exit 0
endef
