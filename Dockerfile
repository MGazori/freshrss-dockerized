FROM php:8.4-fpm-alpine
LABEL authors="mgazori"

WORKDIR /var/www

# Install dependencies and PHP extensions required for FreshRSS
RUN apk update && apk add --no-cache \
    # Build dependencies
    build-base \
    autoconf \
    # General dependencies
    curl \
    git \
    libzip \
    libzip-dev \
    oniguruma-dev \
    icu-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libxml2-dev \
    gmp-dev \
    postgresql-dev \
    sqlite-dev \
    zlib-dev \
    libidn2-dev \
    gnu-libiconv \
    # Install PHP extensions
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        # Core extensions needed
        pdo_mysql \
        pdo_pgsql \
        pdo_sqlite \
        gmp \
        mbstring \
        zip \
        intl \
        opcache \
        gd \
        xml \
        simplexml \
        dom \
    # Enable opcache for better performance
    && echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.max_accelerated_files=4000" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.revalidate_freq=60" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.fast_shutdown=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    # Install composer
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    # Create directory for composer
    && mkdir -p /.composer \
    && chmod -R 777 /.composer \
    # Clean up build dependencies to reduce image size
    && apk del build-base autoconf \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Add GNU libiconv to LD_PRELOAD for proper iconv functionality
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

# Set recommended PHP settings for FreshRSS
RUN { \
    echo 'memory_limit = 128M'; \
    echo 'max_execution_time = 300'; \
    echo 'post_max_size = 32M'; \
    echo 'upload_max_filesize = 32M'; \
    echo 'date.timezone = UTC'; \
    echo 'opcache.enable=1'; \
    echo 'opcache.enable_cli=1'; \
    echo 'zlib.output_compression = On'; \
    echo 'zlib.output_compression_level = 6'; \
    } > /usr/local/etc/php/conf.d/freshRSS-recommended.ini

# Set command
CMD ["php-fpm"]