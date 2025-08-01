name = inception

define export_secrets
	DB_USER=$$(cat secrets/credentials.txt) \
	DB_PASS=$$(cat secrets/db_password.txt) \
	DB_ROOT=$$(cat secrets/db_root_password.txt)
endef

all:
	@printf "Launching configuration ${name}...\n"
	@bash srcs/requirements/wordpress/tools/make_dir.sh
	@$(call export_secrets) docker-compose --env-file srcs/.env -f ./srcs/docker-compose.yml up -d

build:
	@printf "Building configuration ${name}...\n"
	@bash srcs/requirements/wordpress/tools/make_dir.sh
	@$(call export_secrets) docker-compose --env-file srcs/.env -f ./srcs/docker-compose.yml up -d --build

down:
	@docker-compose --env-file srcs/.env -f ./srcs/docker-compose.yml down

re: down
	@$(call export_secrets) docker-compose --env-file srcs/.env -f ./srcs/docker-compose.yml up -d --build

clean: down
	@printf "Cleaning configuration ${name}...\n"
	@docker system prune -a
	@sudo rm -rf ~/data/wordpress/*
	@sudo rm -rf ~/data/mariadb/*

fclean:
	@printf "Total clean of all configurations docker\n"
	@docker stop $$(docker ps -qa)
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force
	@docker volume rm srcs_db-volume || true
	@docker volume rm srcs_wp-volume || true
	@sudo rm -rf ~/data/wordpress/*
	@sudo rm -rf ~/data/mariadb/*

.PHONY	: all build down re clean fclean
