# Use official PHP image with FPM
FROM php:8.1-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libonig-dev \
    zip \
    && docker-php-ext-install pdo_mysql zip

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Generate app key (we’ll override via environment at runtime)
RUN php artisan key:generate

# Expose port 9000 and start php-fpm
EXPOSE 9000
CMD ["php-fpm"]
