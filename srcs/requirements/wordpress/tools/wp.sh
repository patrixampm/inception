#!/bin/bash

# Check if MariaDB is accessible using mysqladmin

#echo if mysqladmin ping -h "${WORDPRESS_DB_HOST}" -u "${MARIADB_USER}" "--password=${MARIADB_PASSWORD}" --silent

mkdir -p /run/php

# Wait until MariaDB is available before proceeding
echo "Waiting for MariaDB to be available..."
for i in {1..60}; do
    if mysqladmin ping -h "${WP_DB_HOST}"  -u "${DB_USER}" "--password=${DB_PASS}" --silent; then
        echo "MariaDB is up."
        break
    else
        echo "MariaDB not available, retrying in 10 seconds..."
        sleep 10
    fi
done

cd /var/www/html

if [ -f wp-config.php ]; then
	echo "wordpress already installed"
else
    # Download WP-CLI if not present
    if [ ! -f /usr/local/bin/wp ]; then
        echo "Downloading WP-CLI..."
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
    fi


# Download wordPress files 
if [ ! -f /usr/local/bin/wp ]; then
    echo "Downloading WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

echo "Downloading WordPress core files..."
wp core download --allow-root

echo "Generating wp-config.php..."
wp config create \
    --dbname=${DB_NAME} \
    --dbuser=${DB_USER} \
    --dbpass=${DB_PASS} \
    --dbhost=${WP_DB_HOST} \
    --allow-root

echo "Installing WordPress..."
wp core install \
    --url=${WP_URL} \
    --title="${TITLE}" \
    --admin_user=${WP_ADMIN_USER} \
    --admin_password=${WP_ADMIN_PASS} \
    --admin_email=${WP_ADMIN_EMAIL} \
    --allow-root

echo "Creating additional WordPress user..."
wp user create ${WP_USER} ${WP_EMAIL} --role=author --user_pass=${WP_PASS} --allow-root

chmod -R 775 wp-content

fi
# Start PHP-FPM
exec php-fpm8.2 -F
