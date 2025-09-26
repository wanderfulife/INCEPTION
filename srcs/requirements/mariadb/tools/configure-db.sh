#!/bin/bash

service mariadb start;

# Create database and user
mariadb -e "CREATE DATABASE IF NOT EXISTS `${MYSQL_DATABASE}`;"
mariadb -e "CREATE USER IF NOT EXISTS `${MYSQL_USER}`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mariadb -e "GRANT ALL PRIVILEGES ON `${MYSQL_DATABASE}`.* TO `${MYSQL_USER}`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mariadb -e "FLUSH PRIVILEGES;"

# Change root password
mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

# Shutdown mariadb to be restarted by CMD
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

exec mysqld_safe
