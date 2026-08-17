.PHONY: keygen build up down restart ps test clean

keygen:
	./setup.sh

build: keygen
	docker compose build

up: build
	docker compose up -d

down:
	docker compose down

restart: down up

ps:
	docker compose ps

test:
	ansible all -m ping

clean: down
	rm -f keys/id_ansible keys/id_ansible.pub
