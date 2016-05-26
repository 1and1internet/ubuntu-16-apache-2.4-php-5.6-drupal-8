FROM 1and1internet/ubuntu-16-apache-2.4-php-5.6:unstable
MAINTAINER james.poole@fasthosts.com
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /var/www/html
COPY files /
ENV DRUPAL_VERSION=8.1.1 \
    DRUPAL_DB_HOST=mysql \
    DRUPAL_DB_PORT=3306 \
    DRUPAL_DB_USER=drupal \
    DRUPAL_DB_NAME=drupal \
    DRUPAL_DB_PASSWORD=EnvVarHere \
    DRUPAL_DB_DRIVER=mysql \
    DRUPAL_DB_PREFIX=''
RUN \
    apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev drush && \
    rm -rf /var/lib/apt/lists/* && \
    curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o /usr/src/drupal.tar.gz && \
    chmod -R 755 /hooks /init
