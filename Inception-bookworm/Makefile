COMPOSE = docker compose
COMPOSE_FILE = ./srcs/docker-compose.yml

all: up

up:
	$(COMPOSE) -f $(COMPOSE_FILE) up --build

down:
	$(COMPOSE) -f $(COMPOSE_FILE) down

start:
	$(COMPOSE) -f $(COMPOSE_FILE) start

stop:
	$(COMPOSE) -f $(COMPOSE_FILE) stop

restart:
	$(COMPOSE) -f $(COMPOSE_FILE) restart

logs:
	$(COMPOSE) -f $(COMPOSE_FILE) logs

ps:
	$(COMPOSE) -f $(COMPOSE_FILE) ps

clean:
	$(COMPOSE) -f $(COMPOSE_FILE) down

fclean: clean
	docker system prune -af

re: fclean up

.PHONY: all up down start stop restart logs ps clean fclean re