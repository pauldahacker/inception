FROM alpine:3.21

# Set environment variables for database connection
ARG DB_NAME
ARG DB_USER
ARG DB_PASS

# Install necessary packages including PHP 8.2 and extensions
RUN apk update && apk upgrade && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-curl \
    php82-dom \
    php82-exif \
    php82-fileinfo \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-zip \
    php82-redis \
    wget \
    unzip && \
    # Configure PHP-FPM to listen on port 9000
    sed -i "s|listen = 127.0.0.1:9000|listen = 9000|g" /etc/php82/php-fpm.d/www.conf && \
    sed -i "s|;listen.owner = nobody|listen.owner = nobody|g" /etc/php82/php-fpm.d/www.conf && \
    sed -i "s|;listen.group = nobody|listen.group = nobody|g" /etc/php82/php-fpm.d/www.conf && \
    rm -f /var/cache/apk/*

# Set working directory
WORKDIR /var/www

# Download and unpack WordPress
RUN wget https://wordpress.org/latest.zip && \
    unzip latest.zip && \
    cp -rf wordpress/* . && \
    rm -rf wordpress latest.zip

# Add and execute WordPress config script
COPY ./requirements/wordpress/conf/wp-config-create.sh .
RUN sh wp-config-create.sh && rm wp-config-create.sh && \
    chmod -R 0777 wp-content/

# Start PHP-FPM server
CMD ["/usr/sbin/php-fpm82", "-F"]

