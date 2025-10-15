NAME = inception
DATA_DIR = $(HOME)/data
WORDPRESS_DATA = $(DATA_DIR)/wordpress
MARIADB_DATA = $(DATA_DIR)/mariadb
DOCKER_COMPOSE = srcs/docker-compose.yml

TEAL = \033[1;36m
MAGENTA = \033[1;35m
GOLD = \033[1;33m
LIME = \033[0;32m
CRIMSON = \033[0;31m
RESET = \033[0m

all: check-dependencies setup start

check-dependencies:
	@echo "$(TEAL)Checking dependencies...$(RESET)"
	@command -v docker >/dev/null 2>&1 || { echo >&2 "Docker is not installed. Please install it first. Aborting."; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || { echo >&2 "Docker Compose is not installed. Aborting."; exit 1; }
	@echo "$(LIME)Dependencies check passed.$(RESET)"

setup:
	@echo "$(TEAL)Creating data directories...$(RESET)"
	@mkdir -p $(MARIADB_DATA)
	@mkdir -p $(WORDPRESS_DATA)
	@echo "$(LIME)Data directories created.$(RESET)"
	@echo "$(TEAL)Setting up directory permissions...$(RESET)"
	@sudo chown -R 999:999 $(MARIADB_DATA) 2>/dev/null || echo "MariaDB permissions set (may need sudo)"
	@sudo chown -R $(shell id -u www-data):$(shell id -g www-data) $(WORDPRESS_DATA) 2>/dev/null || echo "WordPress permissions set (may need sudo)"
	@echo "$(LIME)Directory permissions configured.$(RESET)"

start:
	@echo "$(TEAL)Launching containers...$(RESET)"
	@docker-compose -f $(DOCKER_COMPOSE) up --build -d
	@echo "$(LIME)Containers launched in detached mode. Use 'make logs' to view logs.$(RESET)"

stop:
	@echo "$(TEAL)Stopping containers...$(RESET)"
	@docker-compose -f $(DOCKER_COMPOSE) down
	@echo "$(LIME)Containers stopped successfully.$(RESET)"

status:
	@echo "$(TEAL)Container status:$(RESET)"
	@docker-compose -f $(DOCKER_COMPOSE) ps

logs:
	@echo "$(TEAL)Showing container logs...$(RESET)"
	@docker-compose -f $(DOCKER_COMPOSE) logs -f

clean: stop
	@echo "$(TEAL)Removing containers and images...$(RESET)"
	@docker system prune -af --volumes
	@echo "$(LIME)Cleanup completed.$(RESET)"

fclean: clean
	@echo "$(GOLD)Removing data directories...$(RESET)"
	@sudo chown -R $(shell id -u):$(shell id -g) $(WORDPRESS_DATA) 2>/dev/null || true
	@sudo chown -R $(shell id -u):$(shell id -g) $(MARIADB_DATA) 2>/dev/null || true
	@rm -rf $(WORDPRESS_DATA)
	@rm -rf $(MARIADB_DATA)
	@echo "$(CRIMSON)Data directories removed.$(RESET)"

re: fclean all

vm-start: check-dependencies setup
	@echo "$(TEAL)Starting Inception on VM with proper configuration...$(RESET)"
	@docker-compose -f $(DOCKER_COMPOSE) up --build

.PHONY: all check-dependencies setup start stop status logs clean fclean re vm-start