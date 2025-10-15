#!/bin/bash

# Check if required environment variables are defined
if [ -z "$MARIADB_NAME" ] || [ -z "$MARIADB_USER" ] || [ -z "$MARIADB_USER_PASSWORD" ] || [ -z "$MARIADB_ROOT_PASSWORD" ]; then
    echo "Erreur: Variables d'environnement requises non définies"
    exit 1
fi

# Check if data directory is empty, if so initialize it
# This creates a new database if one doesn't already exist
if [ ! "$(ls -A /var/lib/mysql)" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --basedir=/usr
else
    echo "MariaDB data directory already exists, skipping initialization"
    chown -R mysql:mysql /var/lib/mysql
fi

# Set proper ownership and permissions for MariaDB data directory
chown -R mysql:mysql /var/lib/mysql
chmod -R 755 /var/lib/mysql

# Initialize MariaDB in the background with --skip-networking to prevent external connections during setup
# This allows database setup without exposing the database to external access
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &

# Store the PID of the MariaDB process for later management
MARIADB_PID=$!

# Wait for the process to start
echo "En attente du démarrage de MariaDB..."
counter=0
while [ $counter -lt 30 ]; do
    if mysqladmin ping --silent; then
        echo "MariaDB est démarré"
        break
    fi
    echo "En attente du démarrage de MariaDB... ($counter/30)"
    sleep 2
    ((counter++))
done

if [ $counter -eq 30 ]; then
    echo "Erreur: MariaDB n'a pas démarré correctement"
    exit 1
fi

# Create the database and users with appropriate privileges
# Creates database, user accounts for localhost and remote access, grants permissions
mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS \`${MARIADB_NAME}\`;"
mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS \`${MARIADB_USER}\`@'localhost' IDENTIFIED BY '${MARIADB_USER_PASSWORD}';"
mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS \`${MARIADB_USER}\`@'%' IDENTIFIED BY '${MARIADB_USER_PASSWORD}';"
mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON \`${MARIADB_NAME}\`.* TO \`${MARIADB_USER}\`@'%' IDENTIFIED BY '${MARIADB_USER_PASSWORD}';"
mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON \`${MARIADB_NAME}\`.* TO \`${MARIADB_USER}\`@'localhost' IDENTIFIED BY '${MARIADB_USER_PASSWORD}';"
mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "ALTER USER root@localhost IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"
mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"

echo "MariaDB database and user were created successfully! "

# Shutdown the temporary instance with networking disabled
# This prepares for the final startup with networking enabled
mysqladmin -u root -p${MARIADB_ROOT_PASSWORD} shutdown

# Wait for the process to completely exit
while kill -0 $MARIADB_PID 2>/dev/null; do
  sleep 1
done

# Start MariaDB with networking enabled for the main process
# This is the final startup that serves actual database connections
exec mysqld --user=mysql --datadir=/var/lib/mysql --console