#!/bin/bash

# Start the MariaDB service in the background to perform initial setup.
service mariadb start;

# --- Database and User Creation ---
# The following commands are executed using the `mariadb` client.
# Variables like ${MYSQL_DATABASE} are sourced from the .env file.

# Create the main database for WordPress, but only if it doesn't already exist.
mariadb -e "CREATE DATABASE IF NOT EXISTS `${MYSQL_DATABASE}`;"

# Create the user for WordPress, but only if it doesn't already exist.
# '%' allows the user to connect from any IP address (i.e., from any container on the network).
mariadb -e "CREATE USER IF NOT EXISTS `${MYSQL_USER}`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

# Grant all permissions on the WordPress database to the new user.
mariadb -e "GRANT ALL PRIVILEGES ON `${MYSQL_DATABASE}`.* TO `${MYSQL_USER}`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

# Reload the grant tables to apply the new permissions immediately.
mariadb -e "FLUSH PRIVILEGES;"

# --- Root Password ---
# Set the password for the 'root' user.
# This is important for securing the database.
mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

# --- Shutdown and Restart ---
# Shut down the temporary MariaDB service so it can be restarted properly by the CMD.
# This ensures that the daemon runs in the foreground as the main process of the container.
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# Use `exec` to replace the current script process with the MariaDB daemon.
# `mysqld_safe` is a wrapper that restarts the server if it crashes.
# This makes `mysqld_safe` the main process (PID 1) of the container.
exec mysqld_safe
