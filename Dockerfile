FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git zip unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev curl nodejs npm && \
    docker-php-ext-install pdo pdo_mysql zip bcmath

# Configure GD extension
RUN docker-php-ext-configure gd \
    --with-jpeg=/usr/include \
    --with-freetype=/usr/include && \
    docker-php-ext-install gd

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . .

# Give permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Install node dependencies & build assets
RUN npm install
RUN npm run build

# Laravel cache optimizations
RUN php artisan config:clear
RUN php artisan route:clear
RUN php artisan view:clear

EXPOSE 9000

CMD ["php-fpm"]

