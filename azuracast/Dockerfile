ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system dependencies
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    git \
    supervisor \
    tzdata \
    openssl \
    ca-certificates \
    nginx \
    php81 \
    php81-fpm \
    php81-common \
    php81-curl \
    php81-dom \
    php81-gd \
    php81-intl \
    php81-json \
    php81-mbstring \
    php81-mysqli \
    php81-openssl \
    php81-pdo \
    php81-pdo_mysql \
    php81-session \
    php81-xml \
    php81-zip \
    php81-cli \
    mariadb \
    mariadb-client \
    icecast \
    liquidsoap \
    python3 \
    py3-pip \
    py3-requests

# Install Python packages for Home Assistant integration
RUN pip3 install --no-cache-dir requests pyyaml

# Create application directory
WORKDIR /app

# Copy scripts
COPY run.sh /app/run.sh
COPY ha_integration.py /app/ha_integration.py
RUN chmod a+x /app/run.sh /app/ha_integration.py

# Create necessary directories
RUN mkdir -p /var/www/azuracast \
    /var/log/azuracast \
    /etc/azuracast \
    /data/azuracast/stations \
    /data/azuracast/backups \
    /run/php

# Set environment variables
ENV APPLICATION_ENV="production" \
    AZURACAST_VERSION="latest" \
    PHP_FPM_SOCKET="/run/php/php-fpm.sock"

# Expose ports (main web interface and radio streams)
EXPOSE 80 443 8000-8100

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=180s --retries=3 \
    CMD curl -f http://localhost:80/api/status || exit 1

# Run script
CMD ["/app/run.sh"]
