#!/usr/bin/with-contenv bashio
set -e

# Trap errors and signals
trap 'bashio::log.error "An error occurred during startup"' ERR
trap 'stop_services' SIGTERM SIGINT

stop_services() {
    bashio::log.info "Stopping AzuraCast services..."
    supervisorctl stop all || true
    pkill -f "ha_integration.py" || true
    exit 0
}

bashio::log.info "Starting AzuraCast addon..."

# Get configuration options
AZURACAST_HTTP_PORT=$(bashio::config 'AZURACAST_HTTP_PORT')
AZURACAST_HTTPS_PORT=$(bashio::config 'AZURACAST_HTTPS_PORT')
LETSENCRYPT_ENABLE=$(bashio::config 'LETSENCRYPT_ENABLE')
MYSQL_ROOT_PASSWORD=$(bashio::config 'MYSQL_ROOT_PASSWORD')
MYSQL_USER=$(bashio::config 'MYSQL_USER')
MYSQL_PASSWORD=$(bashio::config 'MYSQL_PASSWORD')
MYSQL_DATABASE=$(bashio::config 'MYSQL_DATABASE')

bashio::log.info "Configuration loaded successfully"

# Generate random passwords if not set
if [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
    MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)
    bashio::log.info "Generated random MySQL root password"
fi

if [ -z "${MYSQL_PASSWORD}" ]; then
    MYSQL_PASSWORD=$(openssl rand -base64 32)
    bashio::log.info "Generated random MySQL user password"
fi

# Create data directories
bashio::log.info "Setting up data directories..."
mkdir -p /data/azuracast/{stations,backups,db,logs,uploads}
mkdir -p /var/log/azuracast

# Initialize MariaDB if needed
if [ ! -d "/data/azuracast/db/mysql" ]; then
    bashio::log.info "Initializing database..."
    mysql_install_db --user=mysql --datadir=/data/azuracast/db > /dev/null

    # Start temporary MySQL server
    mysqld_safe --datadir=/data/azuracast/db --socket=/tmp/mysql.sock &
    MYSQL_PID=$!

    # Wait for MySQL to start
    for i in {1..30}; do
        if mysqladmin ping --socket=/tmp/mysql.sock 2>/dev/null; then
            break
        fi
        sleep 1
    done

    # Set root password and create database
    bashio::log.info "Configuring database..."
    mysql --socket=/tmp/mysql.sock -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql --socket=/tmp/mysql.sock -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
		CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
		FLUSH PRIVILEGES;
	EOSQL

    # Stop temporary MySQL server
    kill $MYSQL_PID
    wait $MYSQL_PID 2>/dev/null || true

    bashio::log.info "Database initialized successfully"
fi

# Configure Nginx
bashio::log.info "Configuring web server..."
cat > /etc/nginx/http.d/azuracast.conf <<EOF
server {
    listen ${AZURACAST_HTTP_PORT};
    listen [::]:${AZURACAST_HTTP_PORT};

    server_name _;
    root /var/www/azuracast/web;
    index index.php;

    access_log /var/log/azuracast/nginx-access.log;
    error_log /var/log/azuracast/nginx-error.log;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:${PHP_FPM_SOCKET};
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location /api {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
}
EOF

# Clone/Update AzuraCast if needed
if [ ! -d "/var/www/azuracast/.git" ]; then
    bashio::log.info "Downloading AzuraCast..."
    git clone --depth=1 https://github.com/AzuraCast/AzuraCast.git /var/www/azuracast
else
    bashio::log.info "AzuraCast already installed"
fi

# Create AzuraCast .env file
cat > /var/www/azuracast/.env <<EOF
APPLICATION_ENV=production
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=${MYSQL_DATABASE}
DB_USERNAME=${MYSQL_USER}
DB_PASSWORD=${MYSQL_PASSWORD}
EOF

# Setup Supervisor configuration
bashio::log.info "Configuring process manager..."
cat > /etc/supervisor/conf.d/azuracast.conf <<EOF
[supervisord]
nodaemon=true
user=root

[program:mariadb]
command=/usr/bin/mysqld_safe --datadir=/data/azuracast/db
autostart=true
autorestart=true
priority=10
stdout_logfile=/var/log/azuracast/mariadb.log
stderr_logfile=/var/log/azuracast/mariadb.error.log

[program:php-fpm]
command=/usr/sbin/php-fpm81 -F
autostart=true
autorestart=true
priority=20
stdout_logfile=/var/log/azuracast/php-fpm.log
stderr_logfile=/var/log/azuracast/php-fpm.error.log

[program:nginx]
command=/usr/sbin/nginx -g 'daemon off;'
autostart=true
autorestart=true
priority=30
stdout_logfile=/var/log/azuracast/nginx.log
stderr_logfile=/var/log/azuracast/nginx.error.log

[program:icecast]
command=/usr/bin/icecast -c /etc/icecast.xml
autostart=true
autorestart=true
priority=40
stdout_logfile=/var/log/azuracast/icecast.log
stderr_logfile=/var/log/azuracast/icecast.error.log

[program:ha-integration]
command=/usr/bin/python3 /app/ha_integration.py
autostart=true
autorestart=true
priority=50
stdout_logfile=/var/log/azuracast/ha-integration.log
stderr_logfile=/var/log/azuracast/ha-integration.error.log
EOF

# Configure Icecast
if [ ! -f "/etc/icecast.xml" ]; then
    bashio::log.info "Configuring Icecast..."
    cat > /etc/icecast.xml <<EOF
<icecast>
    <limits>
        <clients>100</clients>
        <sources>10</sources>
    </limits>
    <authentication>
        <source-password>azuracast</source-password>
        <relay-password>azuracast</relay-password>
        <admin-user>admin</admin-user>
        <admin-password>azuracast</admin-password>
    </authentication>
    <hostname>localhost</hostname>
    <listen-socket>
        <port>8000</port>
    </listen-socket>
    <fileserve>1</fileserve>
    <paths>
        <basedir>/usr/share/icecast</basedir>
        <logdir>/var/log/azuracast</logdir>
        <webroot>/usr/share/icecast/web</webroot>
        <adminroot>/usr/share/icecast/admin</adminroot>
    </paths>
    <logging>
        <accesslog>icecast-access.log</accesslog>
        <errorlog>icecast-error.log</errorlog>
        <loglevel>3</loglevel>
    </logging>
</icecast>
EOF
fi

bashio::log.info "Starting all services..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
