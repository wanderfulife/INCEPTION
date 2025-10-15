# Use Debian Bookworm as the base image
FROM debian:bookworm

# Update package lists and install MariaDB server
RUN apt update && apt upgrade -y && apt install -y mariadb-server

# Create MariaDB configuration file with server settings (datadir, socket, bind address, port, user)
RUN mkdir -p /etc/mysql/mariadb.conf.d && \
    echo "[mysqld]" > /etc/mysql/mariadb.conf.d/50-server.cnf && \
    echo "datadir = /var/lib/mysql" >> /etc/mysql/mariadb.conf.d/50-server.cnf && \
    echo "socket = /run/mysqld/mysqld.sock" >> /etc/mysql/mariadb.conf.d/50-server.cnf && \
    echo "bind-address = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf && \
    echo "port = 3306" >> /etc/mysql/mariadb.conf.d/50-server.cnf && \
    echo "user = mysql" >> /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy the initialization script that handles MariaDB setup and startup
COPY mariadb_init.sh /usr/local/bin/mariadb_init.sh

# Make the initialization script executable and set proper ownership
RUN chmod +x /usr/local/bin/mariadb_init.sh \
&& chown mysql:mysql /usr/local/bin/mariadb_init.sh

# Create runtime directory for MariaDB and set proper ownership
RUN mkdir -p /run/mysqld \
&& chown -R mysql:mysql /run/mysqld

# Expose port 3306 for MariaDB connections
EXPOSE 3306

# Run the initialization script when the container starts
CMD ["/usr/local/bin/mariadb_init.sh"]