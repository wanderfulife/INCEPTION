#!/bin/bash

# Wait for DB
until mariadb -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} &>/dev/null;
do
    echo "Waiting for database..."
    sleep 2
done

if [ ! -f "wp-config.php" ]; then
    wp core download --allow-root

    wp config create --dbname=${MYSQL_DATABASE} --dbuser=${MYSQL_USER} --dbpass=${MYSQL_PASSWORD} --dbhost=mariadb --allow-root

    wp core install --url=${DOMAIN_NAME} --title="Inception" --admin_user=${WP_ADMIN_USER} --admin_password=${WP_ADMIN_PASSWORD} --admin_email=${WP_ADMIN_EMAIL} --allow-root

    wp user create ${WP_USER_LOGIN} ${WP_USER_EMAIL} --role=author --user_pass=${WP_USER_PASSWORD} --allow-root
fi

exec php-fpm7.4 -F
