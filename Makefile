.DEFAULT_GOAL := all

.PHONY: all genenv build down re clean fclean check-secrets

name = inception
HASH_FILE := .secrets_hash
SECRETS_DIR := secrets/
CURRENT_HASH := $(shell find $(SECRETS_DIR) -type f -exec sha256sum {} \; | sha256sum | cut -d' ' -f1)

define export_secrets
	DB_USER=$$(cat secrets/credentials.txt) \
	DB_PASS=$$(cat secrets/db_password.txt) \
	DB_ROOT=$$(cat secrets/db_root_password.txt)
endef

check-secrets:
	@if [ -f $(HASH_FILE) ]; then \
		if [ "$(CURRENT_HASH)" != "$$(cat $(HASH_FILE))" ]; then \
			echo "Detected changes in secrets. Resetting Docker volumes..."; \
			docker compose -f srcs/docker-compose.yml down -v; \
			echo "$(CURRENT_HASH)" > $(HASH_FILE); \
		else \
			echo "✅ Secrets unchanged."; \
		fi \
	else \
		echo "First-time hash record. Saving secrets hash."; \
		echo "$(CURRENT_HASH)" > $(HASH_FILE); \
	fi

genenv: check-secrets
	@echo "Generating .env from secrets/..."
	@for f in credentials.txt db_password.txt db_root_password.txt; do \
		if [ ! -s secrets/$$f ]; then \
			echo "Error: secrets/$$f is missing or empty. Please make changes in secrets/"; \
			exit 1; \
		fi; \
	done
	@admin=$$(cat secrets/credentials.txt); \
	if echo "$$admin" | grep -qi 'admin'; then \
		echo "Error: Admin username cannot contain 'admin' or 'Admin'. Please make changes in secrets/"; \
		exit 1; \
	fi
	@echo "DB_USER=$$(cat secrets/credentials.txt)" > srcs/.env
	@echo "DB_PASS=$$(cat secrets/db_password.txt)" >> srcs/.env
	@echo "DB_ROOT=$$(cat secrets/db_root_password.txt)" >> srcs/.env
	@echo "DB_NAME=wordpress" >> srcs/.env
	@echo "DOMAIN_NAME=pde-masc.42.fr" >> srcs/.env


cert_domain = pde-masc.42.fr
cert_key = $(cert_domain).key
cert_crt = $(cert_domain).crt

gencert:
	@CRT=srcs/requirements/nginx/tools/$(cert_crt); \
	KEY=srcs/requirements/nginx/tools/$(cert_key); \
	if [ ! -f $$CRT ] || [ ! -f $$KEY ]; then \
		echo "Generating TLS certificate for $(cert_domain)..."; \
		mkcert -key-file $(cert_key) -cert-file $(cert_crt) $(cert_domain); \
		mkdir -p srcs/requirements/nginx/tools/ srcs/requirements/tools/; \
		mv $(cert_crt) $(cert_key) srcs/requirements/nginx/tools/; \
		cp srcs/requirements/nginx/tools/$(cert_crt) srcs/requirements/tools/; \
		cp srcs/requirements/nginx/tools/$(cert_key) srcs/requirements/tools/; \
		echo "Certificates generated and copied."; \
	else \
		echo "Certificates already exist. Skipping generation."; \
	fi

all: genenv gencert
	@printf "Launching configuration ${name}...\n"
	@bash srcs/requirements/wordpress/tools/make_dir.sh
	@docker-compose --env-file srcs/.env -f ./srcs/docker-compose.yml up -d --build

build: genenv gencert
	@printf "Building configuration ${name}...\n"
	@bash srcs/requirements/wordpress/tools/make_dir.sh
	@docker-compose --env-file srcs/.env -f ./srcs/docker-compose.yml up -d --build

down:
	@docker-compose --env-file srcs/.env -f ./srcs/docker-compose.yml down

re: down build

clean: down
	@printf "Cleaning configuration ${name}...\n"
	@docker system prune -a

fclean:
	@printf "Total clean of all docker configurations\n"
	@if [ -n "$$(docker ps -q)" ]; then docker stop $$(docker ps -q); fi
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force
	@docker volume rm srcs_db-volume || true
	@docker volume rm srcs_wp-volume || true
	@docker-compose -f srcs/docker-compose.yml down -v --rmi all --remove-orphans
	@sudo rm -rf ~/data/mariadb
	@sudo rm -rf ~/data/wordpress
	@mkdir -p ~/data/mariadb ~/data/wordpress
	@rm -f .secrets_hash || true
	@rm -f srcs/.env || true
	@rm -f srcs/requirements/nginx/tools/*.crt srcs/requirements/nginx/tools/*.key || true
	@rm -f srcs/requirements/tools/*.crt srcs/requirements/tools/*.key || true
