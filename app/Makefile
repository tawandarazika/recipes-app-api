# Makefile wrapper for make.ps1
# Usage examples:
#   make down
#   make up ARGS="--build -d"
#   make test
#   make manage ARGS="shell"

SHELL := /bin/sh

.PHONY: help
help:
	@powershell -NoProfile -ExecutionPolicy Bypass -File ./make.ps1 help

# Forward any target to make.ps1.
# Extra args can be passed via ARGS, e.g.:
#   make logs ARGS="-f app"
%:
	@powershell -NoProfile -ExecutionPolicy Bypass -File ./make.ps1 $@ $(ARGS)
