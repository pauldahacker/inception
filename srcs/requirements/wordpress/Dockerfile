FROM alpine:3.21

# Install
RUN apk update && apk add --no-cache \
    php82 php82-fpm php82-mysqli php82-json php82-mbstring \
    php82-session php82-zlib php82-curl php82-dom php82-opcache \
    php82-phar php82-gd php82-intl php82-pdo php82-pdo_mysql \
    mariadb-client curl  \
    && ln -sf /usr/bin/php82 /usr/bin/php

# Increase PHP memory limit
RUN echo "memory_limit=512M" > /etc/php82/php.ini

RUN sed -i 's|127.0.0.1:9000|0.0.0.0:9000|' /etc/php*/php-fpm.d/www.conf

# Create user & directory
RUN adduser -D -g 'www' www && \
    mkdir -p /var/www && \
    chown -R www:www /var/www

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www
RUN wp core download --allow-root && chown -R www:www /var/www

# Copy files
COPY ./requirements/wordpress/tools/wordpress-entrypoint.sh /usr/local/bin/
COPY ./requirements/wordpress/tools/add_wp_users.sh /var/www/

# Permissions
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh \
    && chmod +x /var/www/add_wp_users.sh

# Set working directory
WORKDIR /var/www

# Set entrypoint
CMD ["wordpress-entrypoint.sh"]
