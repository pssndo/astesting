FROM php:8.3-fpm

WORKDIR /var/www/astesting

RUN apt-get update \
    && apt-get install -y \
        libicu-dev \
        libzip-dev \
        zip \
        unzip \
        nginx \
        wget \
    ` ` tar \
        libfreetype6-dev \
        build-essential \
        nano \
        libmagickwand-dev \
        clang \
        libyaml-dev \
        protoc-gen-go-1-5 \
        protoc-gen-go-grpc \
        --no-install-recommends \
    && docker-php-ext-install \
        intl \
        iconv \
        pdo \
        pdo_mysql \
        zip \
        opcache \
    && pecl install apcu-5.1.21 \
    && pecl install yaml \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable yaml \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/astesting
COPY ./composer.json ./

COPY entrypoint.sh /etc/entrypoint.sh

WORKDIR /var/www/astesting
COPY . /var/www/astesting

RUN composer install --no-scripts --ansi --no-interaction && composer dump-autoload

COPY ./docker/aerospike/aerospike.so /usr/local/lib/php/extensions/no-debug-non-zts-20230831/aerospike.so
RUN echo "extension=aerospike.so" > /usr/local/etc/php/conf.d/aerospike.ini
RUN chmod 644 /usr/local/lib/php/extensions/no-debug-non-zts-20230831/aerospike.so

ENV GO_VERSION 1.22.2

RUN wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

ENV PATH $PATH:/usr/local/go/bin

ENV GOPATH /go
ENV PATH $PATH:$GOPATH/bin

# Create the directory for GOPATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

WORKDIR /var/www/astesting/vendor/aerospike/aerospike-php/aerospike-connection-manager

RUN sed -i 's/host = "127.0.0.1:3000"/host = "aerospike:3000"/g' asld.toml

WORKDIR /var/www/astesting

EXPOSE 9000 9003

RUN chown -R www-data:www-data /var/www/astesting

ENTRYPOINT ["sh", "/etc/entrypoint.sh"]
