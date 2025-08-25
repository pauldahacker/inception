#!/bin/sh

# Wait until WordPress is installed
until wp core is-installed --allow-root --path=/var/www; do
  echo "Waiting for WordPress to be installed..."
  sleep 3
done

# Add admin user pde-masc if not exists
if ! wp user get guest --allow-root --path=/var/www >/dev/null 2>&1; then
  wp user create guest guest@42.com --role=subscriber --user_pass=guest --allow-root --path=/var/www
fi

# Finally, start PHP-FPM in foreground
exec /usr/sbin/php-fpm82 -F
