.PHONY: start remove stop build rebuild drush mysql webshell dbshell composer buildqa help

default: start

start:
#info: start the docker containers
	@echo "Starting containers..."
	@docker-compose up -d --remove-orphans

remove:
#info: stop and remove docker containers
	@echo "Stopping and removing containers"
	@docker-compose down

stop:
#info: stop the docker containers (but don't remove them)
	@echo "Stopping containers"
	@docker-compose stop

clean:
#info: reset files in order to peform a clean install
	@$(MAKE) remove
	@echo "Resetting web directory"
	@[ -d web/sites/default ] && chmod +w web/sites/default && rm -rf web && git checkout -- web || true
	@echo "Resetting mysql database"
	@docker volume rm d8-db 2>/dev/null || true
	@echo "Removing composer lock file"
	@[ -f composer.lock ] && rm -f composer.lock || true
	@echo "Removing vendor directory"
	@[ -d vendor ] && rm -rf vendor || true

build:
#info: build containers and bring up drupal
	@$(MAKE) remove
	@chmod g+w .
	@echo "Building containers"
	docker-compose up -d --build --remove-orphans
	@echo "Running composer install"
	@docker-compose exec --user www-data web composer install
	@echo "Running drupal install"
	@docker-compose exec web drush si standard --db-url=mysql://dbuser:dbpass@db/db --site-name="Drupal 8" -y
	@echo "Drupal should be running on http://localhost:8080"

rebuild:
#info: reset web to repo defaults and rebuild
	@$(MAKE) clean
	@$(MAKE) build

drush:
#info: run a drush command, e.g. make drush arg=status
	@docker-compose exec web drush ${arg}

mysql:
#info: get a mysql command prompt
	@docker-compose exec db mysql -udbuser -pdbpass db

webshell:
#info: open a terminal on the web server
	@docker-compose exec web /bin/bash

dbshell:
#info: open a terminal on the database server
	@docker-compose exec db /bin/bash

composer:
#info: run composer, e.g. make composer arg="require drupal/devel:~1.0"
	@docker-compose exec --user www-data web composer ${arg}

help:
#info: list targets (options)
	@echo "The following targets are available:"
	@echo
	@grep -B1 "^#info" Makefile | sed -e "s/#info://"
