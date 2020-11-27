# seeddms installation
# 
# VERSION 1.2
#

FROM php:7-apache
MAINTAINER Patrick Weber

ENV SEEDDMS_VERSION=6.0.13
ENV LUCENE_VERSION=1.1.11
ENV PREVIEW_VERSION=1.2.9

RUN rm /etc/apt/preferences.d/no-debian-php && \
  apt-get update && \
  apt-get -q -y install \
    libpng-dev \
    imagemagick \
    libmcrypt-dev \
    php-pear \
    poppler-utils \
    catdoc \
    cron \
    curl \
    xmlstarlet \
    php-json \
    php-ldap \
    php-mbstring \
    php-mysql \
    php-sqlite3 \
    php-xml \
    php-xsl \
    php-zip \
    php-soap \
    default-mysql-client \
    default-libmysqlclient-dev \
 && apt-get clean autoclean \
 && apt-get autoremove --yes \
 && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN docker-php-ext-install gd mysqli pdo pdo_mysql

RUN a2enmod php7 && a2enmod rewrite && a2enmod dav && a2enmod dav_fs

RUN a2enmod php7 && a2enmod rewrite && a2enmod dav && a2enmod dav_fs

RUN curl -L https://sourceforge.net/projects/seeddms/files/seeddms-$SEEDDMS_VERSION/SeedDMS_Core-$SEEDDMS_VERSION.tgz/download > SeedDMS_Core-$SEEDDMS_VERSION.tgz  && \
curl -L https://sourceforge.net/projects/seeddms/files/seeddms-$SEEDDMS_VERSION/seeddms-quickstart-$SEEDDMS_VERSION.tar.gz/download > seeddms-quickstart-$SEEDDMS_VERSION.tar.gz  && \
curl -L https://sourceforge.net/projects/seeddms/files/seeddms-$SEEDDMS_VERSION/SeedDMS_Lucene-$LUCENE_VERSION.tgz/download > seedDMS_Lucene-$LUCENE_VERSION.tgz  && \
curl -L https://sourceforge.net/projects/seeddms/files/seeddms-$SEEDDMS_VERSION/SeedDMS_Preview-$PREVIEW_VERSION.tgz/download > SeedDMS_Preview-$PREVIEW_VERSION.tgz
RUN tar xvzf seeddms-quickstart-$SEEDDMS_VERSION.tar.gz --directory /var/www/html && \
pear -v 1 install SeedDMS_Core-$SEEDDMS_VERSION.tgz  && \
pear -v 1 install seedDMS_Lucene-$LUCENE_VERSION.tgz  && \
pear -v 1 install SeedDMS_Preview-$PREVIEW_VERSION.tgz && \
pear -v 1 install Log && pear channel-discover pear.dotkernel.com/zf1/svn && pear install zend/zend && pear install HTTP_WebDAV_Server-1.0.0RC8 && \
mkdir -p /var/templates/seeddms/conf/ && cp seeddms*/conf/settings.xml /var/templates/seeddms/conf/settings.xml && \
rm *.tgz *.tar.gz

ADD configs/php.ini /usr/local/etc/php/
ADD configs/000-default.conf /etc/apache2/sites-available/
ADD entrypoint.sh /opt/entrypoint
ADD scripts/ /opt/seeddms/scripts

RUN mkdir -p /var/www/seeddms &&  mv /var/www/html/*/* /var/www/seeddms && mkdir -p /var/www/seeddms/store/{staging lucene content backup drop} && chown -R www-data:www-data /var/www/seeddms 

RUN /opt/seeddms/scripts/static_change_config.sh
expose 80
ENTRYPOINT ["/opt/entrypoint"]
