#!/bin/bash

# --- Wait for Database ---
# This loop waits until the MariaDB container is ready to accept connections.
# It tries to connect to the database every 2 seconds.
# -h mariadb: specifies the hostname of the database service (defined in docker-compose).
# &>/dev/null: redirects stdout and stderr to null to keep the check silent.
until mariadb -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} &>/dev/null;
do
    echo "Waiting for database..."
    sleep 2
done

# --- WordPress Installation ---
# This block runs only if a wp-config.php file doesn't already exist.
# This prevents re-installing WordPress every time the container restarts.
if [ ! -f "wp-config.php" ]; then

    # Download the WordPress core files.
    # --allow-root is necessary because we are running as the root user in the container.
    wp core download --allow-root

    # Create the wp-config.php file with the database credentials from the .env file.
    wp config create --dbname=${MYSQL_DATABASE} --dbuser=${MYSQL_USER} --dbpass=${MYSQL_PASSWORD} --dbhost=mariadb --allow-root

    # Run the WordPress installation.
    # This sets up the site title, creates the admin user, and sets the site URL.
    wp core install --url=${DOMAIN_NAME} --title="Inception" --admin_user=${WP_ADMIN_USER} --admin_password=${WP_ADMIN_PASSWORD} --admin_email=${WP_ADMIN_EMAIL} --allow-root

    # Create the second, non-admin user.
    wp user create ${WP_USER_LOGIN} ${WP_USER_EMAIL} --role=author --user_pass=${WP_USER_PASSWORD} --allow-root
fi

# --- Start PHP-FPM ---
# Use `exec` to replace the current script process with the PHP-FPM daemon.
# -F (or --nodaemonize) forces PHP-FPM to run in the foreground, which is essential for containers.
# This makes PHP-FPM the main process (PID 1) of the container.
exec php-fpm7.4 -F
