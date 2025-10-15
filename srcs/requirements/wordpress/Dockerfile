FROM debian:bookworm

RUN	apt update && apt install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-cli \
    php8.2-common \
    php8.2-opcache \
    php8.2-xml \
    php8.2-curl \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/wp.sh /usr/local/bin/wp.sh

RUN	chmod +x /usr/local/bin/wp.sh

WORKDIR /var/www/html

EXPOSE 9000

CMD ["/usr/local/bin/wp.sh"]
