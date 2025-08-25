#!/bin/sh
set -e

echo "➡Starting WordPress entrypoint..."
cd /var/www

# Create wp-config.php if it doesn't exist
if [ ! -f "wp-config.php" ]; then
  echo "Creating wp-config.php..."
  wp config create \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="mariadb" \
    --skip-check \
    --allow-root
fi

#Wait for MariaDB to be ready (requires wp-config.php)
echo "Waiting for MariaDB to be ready..."
until wp db check --allow-root > /dev/null 2>&1; do
  sleep 2
done

# Install WordPress if not already installed
if ! wp core is-installed --allow-root; then
  echo "Installing WordPress..."
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="Inception" \
    --admin_user="${DB_USER}" \
    --admin_password="${DB_PASS}" \
    --admin_email="${DB_USER}@example.com" \
    --skip-email \
    --allow-root
fi

# Add your users
sh add_wp_users.sh

# Start PHP-FPM
exec /usr/sbin/php-fpm82 -F
