# Use Debian Bookworm as the base image
FROM debian:bookworm

# Update packages and install PHP with required extensions and MariaDB client
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    wget \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Download and install WP-CLI (WordPress command-line interface) for easier WordPress management
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Download and extract WordPress in French language to the web directory
RUN wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www && \
    cd /var/www && \
    tar -xzf wordpress-6.0-fr_FR.tar.gz && \
    rm wordpress-6.0-fr_FR.tar.gz

# Set proper ownership for WordPress files to allow web server access
RUN chown -R www-data:www-data /var/www/wordpress

# Copy the WordPress initialization script that handles WordPress setup and startup
COPY wordpress_init.sh /usr/local/bin/wordpress_init.sh
RUN chmod +x /usr/local/bin/wordpress_init.sh

# Create PHP-FPM configuration for the WordPress pool with proper user settings and process management
RUN echo "[www]" > /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "user = www-data" >> /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "group = www-data" >> /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "" >> /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "listen = 9000" >> /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "listen.owner = www-data" >> /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "listen.group = www-data" >> /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "" >> /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "pm = dynamic" >> /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "pm.max_children = 5" >> /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "pm.start_servers = 2" >> /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "pm.min_spare_servers = 1" >> /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "pm.max_spare_servers = 3" >> /etc/php/8.2/fpm/pool.d/www.conf

# Create PHP-FPM runtime directory
RUN mkdir -p /run/php

# Run the initialization script when the container starts
ENTRYPOINT ["/usr/local/bin/wordpress_init.sh"]
