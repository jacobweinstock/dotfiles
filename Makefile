include dotfiles.vars
SHELL_ORIGINAL := $(shell echo $$SHELL)
SHELL := /usr/bin/env bash
OSFLAG := $(shell uname -s)

.DEFAULT_GOAL := help

.PHONY: all
all: shell_install nix gitconfig reload

.PHONY: reload
reload: ## Reload the shell
	exec $(SHELL_ORIGINAL)
	@echo

.PHONY: shell_install
shell_install: ## Install shell .rc file
	
ifeq ($(SHELL_ORIGINAL),/bin/zsh)
		# install .zshrc
		ln -snf $(CURDIR)/.rc $(HOME)/.zshrc
		source $(HOME)/.zshrc
else
		# install .bashrc
		ln -snf $(CURDIR)/.rc $(HOME)/.bashrc
		source $(HOME)/.bashrc
endif
		@echo

.PHONY: shell_remove
shell_remove: ## Remove shell .rc file
ifeq ($(SHELL),/bin/zsh)
		# remove .zshrc
		rm -rf $(HOME)/.zshrc
else
		# remove .bashrc
		rm -rf $(HOME)/.bashrc
endif
		@echo

.PHONY: nix
nix: ## Install config.nix
		# install nix
ifeq (,$(shell which nix-env))
		@echo installing nix...
ifeq ($(OSFLAG),Darwin)
		sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume
endif
		bash <(curl -L https://nixos.org/nix/install)
endif
		@echo

		# nix pkgs
		mkdir -p $(HOME)/.nixpkgs
		ln -snf $(CURDIR)/.nixpkgs/config.nix $(HOME)/.nixpkgs
		@echo

		# install pkgs
		nix-env -i localDev
		@echo

.PHONY: nix_remove
nix_remove: ## Remove config.nix and nix install
		# remove nix pkgs
		@echo removing nix...
		nix-env -e localDev || true
		rm -rf $(HOME)/.nixpkgs
		@echo

		# remove nix
		rm -rf $(HOME)/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs}
		sudo rm -rf /nix || true
		@echo

.PHONY: gitconfig
gitconfig: ## Install .gitconfig
		# global git config
		ln -snf $(CURDIR)/.gitconfig $(HOME)/.gitconfig
		git config --global user.name ${GIT_USER_NAME}
		git config --global user.email ${GIT_USER_EMAIL}
		@echo

.PHONY: gitconfig_remove
gitconfig_remove: ## Remove .gitconfig install
		# global git config
		rm -rf $(HOME)/.gitconfig
		@echo

.PHONY: wipe
wipe: gitconfig_remove nix_remove shell_remove reload

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk '{sub(/^Makefile:/, "")}1' | awk 'BEGIN {FS = ": ##"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
