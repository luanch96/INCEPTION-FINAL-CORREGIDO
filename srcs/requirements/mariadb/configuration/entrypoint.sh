#!/bin/bash

set -e

echo "Iniciando MariaDB..."

DB_ROOT_PASSWORD=$(cat /run/secrets/mariadb_root_password)
DB_USER=$(cat /run/secrets/mariadb_user)
DB_PASSWORD=$(cat /run/secrets/mariadb_password)

chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /var/log/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Inicializando base de datos MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db
    echo "Base de datos inicializada"
    
    echo "Configurando usuarios y base de datos..."
    
    mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 &
    MYSQL_PID=$!
    
    sleep 5
    
    mysql -e "
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.user WHERE User='root';
        DELETE FROM mysql.db WHERE User='root' OR User='';
        DELETE FROM mysql.tables_priv WHERE User='root' OR User='';
        DELETE FROM mysql.columns_priv WHERE User='root' OR User='';
        FLUSH PRIVILEGES;
        CREATE USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        CREATE USER 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        ALTER USER 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
        CREATE DATABASE IF NOT EXISTS wordpress;
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON wordpress.* TO '${DB_USER}'@'%';
        FLUSH PRIVILEGES;
    "
    
    kill $MYSQL_PID
    wait $MYSQL_PID
    
    echo "Usuario y base de datos configurados"
fi

mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

echo "Iniciando MariaDB..."

# Crear script para verificar/crear usuario después de iniciar y asegurar seguridad
cat > /tmp/ensure_db_user.sh <<EOF
#!/bin/bash
for i in {1..60}; do
    if mysqladmin ping --silent --socket=/var/run/mysqld/mysqld.sock 2>/dev/null; then
        # Primero asegurar que root tiene contraseña
        mysql -uroot -p"${DB_ROOT_PASSWORD}" -e "
            DELETE FROM mysql.user WHERE User='root' AND (plugin='unix_socket' OR plugin='' OR plugin IS NULL);
            DELETE FROM mysql.db WHERE User='root';
            ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
            ALTER USER 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
            UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';
            CREATE USER IF NOT EXISTS 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
            CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
            ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
            ALTER USER 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
            UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';
            GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
            GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
        " 2>/dev/null || true
        
        # Crear base de datos y usuario de WordPress
        mysql -uroot -p"${DB_ROOT_PASSWORD}" -e "
            CREATE DATABASE IF NOT EXISTS wordpress;
            CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
            GRANT ALL PRIVILEGES ON wordpress.* TO '${DB_USER}'@'%';
            FLUSH PRIVILEGES;
        " 2>/dev/null && echo "Usuario y base de datos verificados/creados" && break || echo "Esperando... ($i/60)"
    fi
    sleep 1
done
EOF
chmod +x /tmp/ensure_db_user.sh
/tmp/ensure_db_user.sh &

# Crear script que verifica periódicamente que root requiere contraseña
cat > /tmp/ensure_root_password.sh <<EOF
#!/bin/bash
while true; do
    sleep 30
    if mysqladmin ping --silent --socket=/var/run/mysqld/mysqld.sock 2>/dev/null; then
        mysql -uroot -p"${DB_ROOT_PASSWORD}" -e "
            DELETE FROM mysql.user WHERE User='root' AND (plugin='unix_socket' OR plugin='' OR plugin IS NULL);
            DELETE FROM mysql.db WHERE User='root';
            ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
            ALTER USER 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
            UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';
            FLUSH PRIVILEGES;
        " 2>/dev/null || true
    fi
done
EOF
chmod +x /tmp/ensure_root_password.sh
/tmp/ensure_root_password.sh &

exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0