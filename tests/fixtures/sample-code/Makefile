SHELL := /bin/bash
.DEFAULT_GOAL := help

RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
NC := \033[0m

PROJECT_NAME := sentry-sentinel-theme
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_SHA := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

SRC_DIR := src
DIST_DIR := dist
VSCODE_DIR := vscode
EXAMPLES_DIR := examples
SCRIPTS_DIR := scripts

SENTRY_ORG ?= your-org
SENTRY_PROJECT ?= your-project
SENTRY_AUTH_TOKEN ?= $(shell echo $$SENTRY_AUTH_TOKEN)

NPM := npm
NODE := node
NPM_FLAGS := --silent

.PHONY: all help install build test lint format clean release deploy docker

## help: Display this help message
help:
	@echo -e "$(PURPLE)$(PROJECT_NAME) - Build System$(NC)"
	@echo -e "$(BLUE)Version:$(NC) $(VERSION)"
	@echo -e "$(BLUE)Commit:$(NC) $(COMMIT_SHA)"
	@echo ""
	@echo -e "$(YELLOW)Available targets:$(NC)"
	@grep -E '^##' $(MAKEFILE_LIST) | sed -E 's/^## //' | column -t -s ':'

## install: Install all dependencies
install: install-node install-vscode
	@echo -e "$(GREEN)✓ All dependencies installed$(NC)"

install-node:
	@echo -e "$(BLUE)Installing Node dependencies...$(NC)"
	@$(NPM) install $(NPM_FLAGS)

install-vscode:
	@echo -e "$(BLUE)Installing VS Code extension dependencies...$(NC)"
	@cd $(VSCODE_DIR) && $(NPM) install $(NPM_FLAGS)

## build: Build all theme variants
build: clean validate
	@echo -e "$(BLUE)Building themes...$(NC)"
	@mkdir -p $(DIST_DIR)
	@$(NPM) run build
	@echo -e "$(GREEN)✓ Build complete$(NC)"

## test: Run all tests
test: test-colors test-contrast test-unit
	@echo -e "$(GREEN)✓ All tests passed$(NC)"

test-colors:
	@echo -e "$(BLUE)Validating color definitions...$(NC)"
	@$(NODE) $(SCRIPTS_DIR)/validate-colors.js

test-contrast:
	@echo -e "$(BLUE)Testing WCAG contrast ratios...$(NC)"
	@$(NODE) $(SCRIPTS_DIR)/test-contrast.js

test-unit:
	@echo -e "$(BLUE)Running unit tests...$(NC)"
	@$(NPM) test $(NPM_FLAGS)

## lint: Lint all code files
lint: lint-js lint-json lint-md
	@echo -e "$(GREEN)✓ Linting complete$(NC)"

lint-js:
	@echo -e "$(BLUE)Linting JavaScript files...$(NC)"
	@npx eslint $(SCRIPTS_DIR)/**/*.js --fix

lint-json:
	@echo -e "$(BLUE)Linting JSON files...$(NC)"
	@npx prettier --write '**/*.json'

lint-md:
	@echo -e "$(BLUE)Linting Markdown files...$(NC)"
	@npx markdownlint '**/*.md' --fix

## format: Format all files with Prettier
format:
	@echo -e "$(BLUE)Formatting files...$(NC)"
	@npx prettier --write '**/*.{json,md,yml,yaml,js,ts,css,scss,html}'
	@echo -e "$(GREEN)✓ Formatting complete$(NC)"

## preview: Preview theme in terminal
preview:
	@$(NODE) $(SCRIPTS_DIR)/preview-theme.js

## validate: Validate all theme files
validate:
	@echo -e "$(BLUE)Validating theme files...$(NC)"
	@$(NODE) $(SCRIPTS_DIR)/validate-colors.js
	@echo -e "$(GREEN)✓ Validation passed$(NC)"

## package: Package VS Code extension
package: build
	@echo -e "$(BLUE)Packaging VS Code extension...$(NC)"
	@cd $(VSCODE_DIR) && npx vsce package
	@echo -e "$(GREEN)✓ Extension packaged$(NC)"

## publish: Publish VS Code extension to marketplace
publish: package
	@echo -e "$(BLUE)Publishing to VS Code marketplace...$(NC)"
	@cd $(VSCODE_DIR) && npx vsce publish
	@echo -e "$(GREEN)✓ Extension published$(NC)"

## release: Create a new release with Sentry
release: build test
	@echo -e "$(BLUE)Creating Sentry release $(VERSION)...$(NC)"
	@if [ -n "$(SENTRY_AUTH_TOKEN)" ]; then \
		sentry-cli releases new $(VERSION) \
			--org $(SENTRY_ORG) \
			--project $(SENTRY_PROJECT); \
		sentry-cli releases set-commits $(VERSION) --auto; \
		sentry-cli releases finalize $(VERSION); \
		echo -e "$(GREEN)✓ Release created$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠ SENTRY_AUTH_TOKEN not set, skipping Sentry release$(NC)"; \
	fi

## deploy: Deploy release to environment
deploy: release
	@echo -e "$(BLUE)Deploying $(VERSION) to production...$(NC)"
	@if [ -n "$(SENTRY_AUTH_TOKEN)" ]; then \
		sentry-cli releases deploys $(VERSION) new -e production; \
		echo -e "$(GREEN)✓ Deployed to production$(NC)"; \
	fi

## docker: Build Docker image
docker:
	@echo -e "$(BLUE)Building Docker image...$(NC)"
	@docker build \
		--build-arg VERSION=$(VERSION) \
		--build-arg SENTRY_AUTH_TOKEN=$(SENTRY_AUTH_TOKEN) \
		-t $(PROJECT_NAME):$(VERSION) \
		-t $(PROJECT_NAME):latest \
		.
	@echo -e "$(GREEN)✓ Docker image built$(NC)"

## clean: Clean build artifacts
clean:
	@echo -e "$(BLUE)Cleaning build artifacts...$(NC)"
	@rm -rf $(DIST_DIR)
	@rm -rf node_modules
	@rm -rf $(VSCODE_DIR)/node_modules
	@rm -f $(VSCODE_DIR)/*.vsix
	@find . -name "*.log" -delete
	@echo -e "$(GREEN)✓ Clean complete$(NC)"

## install-tools: Install required global tools
install-tools:
	@echo -e "$(BLUE)Installing global tools...$(NC)"
	@npm install -g @sentry/cli vsce prettier eslint markdownlint-cli
	@echo -e "$(GREEN)✓ Tools installed$(NC)"

## dev: Start development mode
dev:
	@echo -e "$(BLUE)Starting development mode...$(NC)"
	@tmux new-session -d -s $(PROJECT_NAME) || true
	@tmux send-keys -t $(PROJECT_NAME) "npm run watch" C-m
	@tmux split-window -t $(PROJECT_NAME) -h
	@tmux send-keys -t $(PROJECT_NAME) "cd $(VSCODE_DIR) && code ." C-m
	@tmux attach -t $(PROJECT_NAME)

## stats: Show project statistics
stats:
	@echo -e "$(PURPLE)Project Statistics$(NC)"
	@echo -e "$(BLUE)Lines of code:$(NC)"
	@find . -name "*.json" -o -name "*.js" -o -name "*.ts" | xargs wc -l | tail -1
	@echo -e "$(BLUE)Number of theme files:$(NC)"
	@find . -name "*theme*.json" | wc -l
	@echo -e "$(BLUE)Git commits:$(NC)"
	@git rev-list --count HEAD 2>/dev/null || echo "0"

## check-deps: Check for outdated dependencies
check-deps:
	@echo -e "$(BLUE)Checking for outdated dependencies...$(NC)"
	@npm outdated || true
	@cd $(VSCODE_DIR) && npm outdated || true

## update-deps: Update all dependencies
update-deps:
	@echo -e "$(BLUE)Updating dependencies...$(NC)"
	@npm update
	@cd $(VSCODE_DIR) && npm update
	@echo -e "$(GREEN)✓ Dependencies updated$(NC)"

## pr: Prepare pull request (format, lint, test)
pr: format lint test
	@echo -e "$(GREEN)✓ Ready for pull request$(NC)"

.SILENT: help stats

-include .env

TIMEFORMAT="Task completed in %R seconds"
time-%:
	@time $(MAKE) $*
