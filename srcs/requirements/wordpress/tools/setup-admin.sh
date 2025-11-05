#!/bin/bash

set -e

MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mariadb_root_password)
DB_USER=$(cat /run/secrets/mariadb_user)
DB_PASSWORD=$(cat /run/secrets/mariadb_password)

# Obtener variables de entorno
WP_ADMIN_USER=${WP_ADMIN_USER:-luisanch}
WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD:-jiji_porfin}
WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-luisanch@42.fr}
WP_TITLE=${WP_TITLE:-Mi WordPress}
DOMAIN_NAME=${DOMAIN_NAME:-luisanch.42.fr}

echo "Esperando a que MariaDB esté lista..."
until mysql -h mariadb -u $DB_USER -p$DB_PASSWORD -e "SELECT 1" >/dev/null 2>&1; do
    echo "Esperando a que MariaDB esté lista..."
    sleep 2
done

echo "MariaDB está lista. Configurando WordPress..."

cd /var/www/wordpress

# Asegurar que wp-config.php existe y está configurado correctamente
if [ ! -f wp-config.php ]; then
    echo "Error: wp-config.php no encontrado. Debe estar presente en la construcción de la imagen."
    exit 1
fi

# Esperar un poco más para asegurar que la base de datos esté completamente lista
sleep 3

# Verificar si WordPress ya está instalado
INSTALLED=$(wp core is-installed --allow-root 2>/dev/null || echo "no")

if [ "$INSTALLED" != "yes" ]; then
    echo "Instalando WordPress..."
    
    # Instalar WordPress usando WP-CLI
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
    
    echo "WordPress instalado correctamente."
    echo "Usuario administrador: ${WP_ADMIN_USER}"
    echo "Contraseña: ${WP_ADMIN_PASSWORD}"
else
    echo "WordPress ya está instalado. Saltando instalación..."
fi

# Configurar permisos
chown -R www-data:www-data /var/www/wordpress
chmod -R 755 /var/www/wordpress

echo "WordPress está listo. Accede a https://${DOMAIN_NAME}/wp-login.php"