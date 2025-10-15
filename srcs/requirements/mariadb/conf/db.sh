#!/bin/sh

# Check if MySQL system database exists

if [ ! -d "/var/lib/mysql/mysql" ]; then

	echo "Initializing MariaDB data directory..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	chown -R mysql:mysql /var/lib/mysql

	# Init the database
	mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm

	tfile=$(mktemp)
	if [ ! -f "$tfile" ]; then
		echo "Error: Failed to create temp file."
		exit 1
	fi
fi

# Check if the WordPress database exists

if [ ! -d "/var/lib/mysql/${DB_NAME}" ]; then
	echo "Creating database and user..."

	# Start MariaDB temporarily in background
    /usr/bin/mysqld --user=mysql --datadir=/var/lib/mysql &
    pid="$!"
    
    # Wait for MariaDB to be ready
    echo "Waiting for MariaDB to start..."
    sleep 5
    
    # Create database and user
    mysql -u root << EOF
USE mysql;
FLUSH PRIVILEGES;

DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';

DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';

CREATE DATABASE ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	# Stop the temporary MariaDB
    kill "$pid"
    wait "$pid"
    
    echo "Database setup complete."
fi

# Start MariaDB in foreground (keeps container running)
echo "Starting MariaDB..."
exec /usr/bin/mysqld --user=mysql --datadir=/var/lib/mysql
