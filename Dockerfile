FROM php:8.2-fpm

# System dependencies
RUN apt-get update && apt-get install -y \
    git zip unzip libzip-dev curl \
    nodejs npm nginx \
    && docker-php-ext-install pdo pdo_mysql zip

# Set working directory
WORKDIR /var/www

# Copy entire app
COPY . .

# Copy Nginx config from your nginx/default.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Fix permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

# Install Node deps and build assets
RUN npm install
RUN npm run build

# Generate APP_KEY
RUN php artisan key:generate --force

EXPOSE 9000
CMD ["php-fpm"]
