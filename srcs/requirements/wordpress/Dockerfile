FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    curl \
    php-fpm \
    php-mysql \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY tools/configure-wp.sh /usr/local/bin/configure-wp.sh
RUN chmod +x /usr/local/bin/configure-wp.sh

RUN mkdir -p /var/www/html /run/php
WORKDIR /var/www/html

# Change php-fpm to listen on 9000
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

EXPOSE 9000

CMD ["/usr/local/bin/configure-wp.sh"]
