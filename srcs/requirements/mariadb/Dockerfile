FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/lib/mysql /var/run/mysqld /var/log/mysql
RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /var/log/mysql

RUN echo "[mysqld]" > /etc/mysql/mariadb.conf.d/50-server.cnf && \
    echo "datadir = /var/lib/mysql" >> /etc/mysql/mariadb.conf.d/50-server.cnf && \
    echo "socket = /var/run/mysqld/mysqld.sock" >> /etc/mysql/mariadb.conf.d/50-server.cnf && \
    echo "log-error = /var/log/mysql/error.log" >> /etc/mysql/mariadb.conf.d/50-server.cnf && \
    echo "pid-file = /var/run/mysqld/mysqld.pid" >> /etc/mysql/mariadb.conf.d/50-server.cnf && \
    echo "user = mysql" >> /etc/mysql/mariadb.conf.d/50-server.cnf && \
    echo "bind-address = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf && \
    echo "port = 3306" >> /etc/mysql/mariadb.conf.d/50-server.cnf

RUN echo "[mysqld]" > /etc/mysql/mariadb.conf.d/99-disable-unix-socket-auth.cnf && \
    echo "skip-grant-tables = 0" >> /etc/mysql/mariadb.conf.d/99-disable-unix-socket-auth.cnf && \
    echo "[mariadb]" >> /etc/mysql/mariadb.conf.d/99-disable-unix-socket-auth.cnf && \
    echo "plugin-load-add = auth_socket=OFF" >> /etc/mysql/mariadb.conf.d/99-disable-unix-socket-auth.cnf

COPY configuration/settings.sh /docker-entrypoint-initdb.d/settings.sh.template
RUN chmod +x /docker-entrypoint-initdb.d/settings.sh.template

COPY configuration/init-db.sql /docker-entrypoint-initdb.d/init-db.sql

COPY configuration/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]