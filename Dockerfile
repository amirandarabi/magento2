FROM ubuntu:18.04
WORKDIR /var/www/html/magento2
ARG PHP_VERIOSN , COMPOSER_VERSION
RUN apt-get update && apt install lsb-release ca-certificates apt-transport-https software-properties-common net-tools vim curl tzdata nginx -y && add-apt-repository ppa:ondrej/php 
ENV TZ=Asia/Tehran 
ARG PHP_VERIOSN=7.4
ARG COMPOSER_VERSION=1.10.26

RUN apt update && apt install php$PHP_VERIOSN  php$PHP_VERIOSN-cli php$PHP_VERIOSN-common php$PHP_VERIOSN-imap php$PHP_VERIOSN-redis php$PHP_VERIOSN-snmp php$PHP_VERIOSN-xml php$PHP_VERIOSN-zip php$PHP_VERIOSN-mbstring php$PHP_VERIOSN-curl php$PHP_VERIOSN-gd php$PHP_VERIOSN-intl php$PHP_VERIOSN-mysql php$PHP_VERIOSN-soap php$PHP_VERIOSN-bcmath php$PHP_VERIOSN-fpm -y 
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && php composer-setup.php --version $COMPOSER_VERSION && php -r "unlink('composer-setup.php');" && mv composer.phar /usr/local/bin/composer 
ADD composer.json composer.json
ADD auth.json auth.json
RUN composer install 
ADD . .
RUN chown -R www-data:www-data /var/www/html/magento2/ && chmod 777 -R var && chmod 777 -R generated && chmod 777 -R app/etc && rm -rf var/cache/* var/page_cache/* var/generation/* && php bin/magento setup:di:compile;
CMD ["bin/magento", "setup:install", "--base-url=$MAGENTO_URL", "--db-host=$MYSQL_HOST", "--db-name=$MYSQL_DATABASE", "--db-user=$MYSQL_USER","--db-password=$MYSQL_PASSWORD","--search-engine=$MAGENTO_ADMIN_SEARCH_ENGINE", "--elasticsearch-host=$MAGENTO_ELASTICSEARCH_HOST","--elasticsearch-port=$MAGENTO_ELASTICSEARCH_PORT", "--cleanup-database", "--enable-debug-logging", "--enable-syslog-logging"]
