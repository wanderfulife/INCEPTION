# Use the penultimate stable version of Debian as the base image.
FROM debian:bullseye

# Update package list and install necessary packages.
RUN apt-get update && apt-get install -y \
    curl \
    php-fpm \
    php-mysql \
    # curl is needed to download wp-cli.
    # php-fpm is the PHP FastCGI Process Manager.
    # php-mysql allows PHP to connect to the MariaDB database.
    && rm -rf /var/lib/apt/lists/* # Clean up apt cache to keep image size small.

# Download the WordPress Command Line Interface (wp-cli).
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    # Make the downloaded file executable.
    && chmod +x wp-cli.phar \
    # Move it to a directory in the system's PATH to make it a global command.
    && mv wp-cli.phar /usr/local/bin/wp

# Copy the WordPress configuration script into the container.
COPY tools/configure-wp.sh /usr/local/bin/configure-wp.sh
# Make the script executable.
RUN chmod +x /usr/local/bin/configure-wp.sh

# Create the web root directory and the directory for the php-fpm socket.
RUN mkdir -p /var/www/html /run/php
# Set the working directory. Subsequent commands will run here.
WORKDIR /var/www/html

# Copy the custom PHP-FPM pool configuration file.
# This is configured to listen on a network port instead of a Unix socket.
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Expose port 9000, which PHP-FPM will listen on for incoming requests from NGINX.
EXPOSE 9000

# Set the command to run when the container starts.
# This script will configure WordPress and then start the PHP-FPM service.
CMD ["/usr/local/bin/configure-wp.sh"]
