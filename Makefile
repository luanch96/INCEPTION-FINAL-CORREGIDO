

COMPOSE_CMD = docker-compose -f srcs/docker-compose.yml
DOMAIN_NAME ?= luisanch.42.fr

export DOMAIN_NAME

.PHONY: all build up run down restart clean fclean test ensure-data-dir set-permissions check-port80 stop-apache2

all: run

set-permissions:
	@echo "Configurando permisos de ejecución para scripts..."
	@chmod +x setup-database.sh 2>/dev/null || true
	@chmod +x srcs/requirements/nginx/tools/generate-ssl.sh 2>/dev/null || true
	@chmod +x srcs/requirements/mariadb/configuration/entrypoint.sh 2>/dev/null || true
	@chmod +x srcs/requirements/mariadb/configuration/settings.sh 2>/dev/null || true
	@chmod +x srcs/requirements/wordpress/tools/setup-admin.sh 2>/dev/null || true
	@echo "Permisos configurados correctamente"

check-port80:
	@echo "Verificando puerto 80..."
	@if command -v ss >/dev/null 2>&1; then \
		if ss -tulpn | grep -q ':80 '; then \
			echo "⚠️  ADVERTENCIA: El puerto 80 está en uso."; \
			echo "Para detener Apache2 permanentemente, ejecuta:"; \
			echo "  sudo systemctl stop apache2"; \
			echo "  sudo systemctl disable apache2"; \
			echo ""; \
			echo "O ejecuta: make stop-apache2"; \
			exit 1; \
		fi; \
	fi

stop-apache2:
	@echo "Deteniendo Apache2..."
	@sudo systemctl stop apache2 2>/dev/null || echo "Apache2 no está corriendo o requiere permisos"
	@sudo systemctl disable apache2 2>/dev/null || echo "No se pudo deshabilitar Apache2 (puede requerir permisos)"
	@echo "Apache2 detenido y deshabilitado"

ensure-data-dir: set-permissions check-port80
	@echo "Verificando directorio de datos..."
	@mkdir -p /home/luisanch/data/mariadb /home/luisanch/data/wordpress /home/luisanch/data/ssl 2>/dev/null || \
		(sudo mkdir -p /home/luisanch/data/mariadb /home/luisanch/data/wordpress /home/luisanch/data/ssl && \
		 sudo chown -R luisanch:luisanch /home/luisanch/data/)
	@chown -R luisanch:luisanch /home/luisanch/data/ 2>/dev/null || true
	@if [ ! -f /home/luisanch/data/ssl/nginx.crt ] || [ ! -f /home/luisanch/data/ssl/nginx.key ]; then \
		echo "Generando certificados SSL para $(DOMAIN_NAME)..."; \
		./srcs/requirements/nginx/tools/generate-ssl.sh; \
	fi
	@echo "Directorio de datos listo"

build: ensure-data-dir
	$(COMPOSE_CMD) build

up: ensure-data-dir
	$(COMPOSE_CMD) up -d

run: build up
	@echo "Todos los contenedores se han iniciado correctamente."
	@echo "Accede a https://$(DOMAIN_NAME)"

down:
	$(COMPOSE_CMD) down -v

restart: down up

clean:
	@docker stop $$(docker ps -qa) 2>/dev/null || true; \
	docker rm $$(docker ps -qa) 2>/dev/null || true; \
	docker rmi -f $$(docker images -qa) 2>/dev/null || true; \


fclean: clean
	sudo rm -rf /home/luisanch/data/mariadb/*
	sudo rm -rf /home/luisanch/data/wordpress/*
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true; \
	docker network rm $$(docker network ls -q) 2>/dev/null || true; \
	docker system prune -f --volumes
	docker system prune -a 
	@echo "Todo limpio"


setup:
	@echo "Creando directorios para volúmenes..."
	sudo mkdir -p /home/luisanch/data/mariadb
	sudo mkdir -p /home/luisanch/data/wordpress
	sudo mkdir -p /home/luisanch/data/ssl
	sudo chown -R luisanch:luisanch /home/luisanch/data/
	@echo "Generando certificados SSL para $(DOMAIN_NAME)..."
	./srcs/requirements/nginx/tools/generate-ssl.sh
	@echo "Directorios creados correctamente"

info:
	@echo "Servicios disponibles:"
	@echo "  WordPress: https://$(DOMAIN_NAME)"
	@echo ""
	@echo "Estado de contenedores:"
	@$(COMPOSE_CMD) ps