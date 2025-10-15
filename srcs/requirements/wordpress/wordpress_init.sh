#!/bin/bash
# Create PHP runtime directory if it doesn't exist
if [ ! -d "/run/php" ]; then
  mkdir /run/php
fi

# Check if required environment variables are set
if [ -z "${DOMAIN_NAME}" ] || [ -z "${WORDPRESS_ADMIN_USER}" ] || [ -z "${WORDPRESS_ADMIN_PASSWORD}" ]; then
  echo "Error: Required environment variables are not set."
  exit 1
fi

# Change directory to WordPress installation
cd /var/www/wordpress

# Wait for MariaDB to be ready by checking connectivity
echo "En attente de la base de données..."
counter=0
while [ $counter -lt 30 ]; do
  if mysql -h "mariadb" -u "$MARIADB_USER" -p"$MARIADB_USER_PASSWORD" -e "SHOW DATABASES;" > /dev/null 2>&1; then
    echo "Database is ready"
    break
  fi
  echo "Database is not ready. Retrying in 5 seconds... ($counter/30)"
  sleep 5
  ((counter++))
done

if [ $counter -eq 30 ]; then
  echo "Erreur: Database is not accessible"
  exit 1
fi

# Check if WordPress is already installed by looking for wp-config.php
# If not installed, perform initial setup using WP-CLI
if [ ! -f "/var/www/wordpress/wp-config.php" ]; then

  echo "WordPress is not installed. Installing..."
  # Download WordPress files if not present
  wp core download --allow-root

  # Create wp-config.php with database connection settings
  wp core config \
      --dbhost="$MARIADB_HOST" \
      --dbname="$MARIADB_NAME" \
      --dbuser="$MARIADB_USER" \
      --dbpass="$MARIADB_USER_PASSWORD" \
      --allow-root

  # Install WordPress with specified site details
  wp core install --allow-root \
    --url="${DOMAIN_NAME}" \
    --title="${WORDPRESS_TITLE}" \
    --admin_user="${WORDPRESS_ADMIN_USER}" \
    --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
    --skip-email

  # Create a secondary user with author role
  wp user create --allow-root \
    "${WORDPRESS_USER2}" \
    "${WORDPRESS_USER2_EMAIL}" \
    --role="author" \
    --user_pass="${WORDPRESS_USER2_PASSWORD}"
fi

echo "WordPress is installed"

echo "starting wordpress"

# Start PHP-FPM in foreground mode to serve WordPress requests
exec php-fpm8.2 -F --allow-to-run-as-root
