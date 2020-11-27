#!/bin/bash

set -e
if [ -n "$TZ" ]; then
	  echo $TZ > /etc/timezone
fi

rm -f /etc/cron.d/seeddms

if [ -n "$CRON_INDEX" ]; then
	   echo "$CRON_INDEX su -s /bin/bash -c /usr/local/bin/seeddms-generate-index.sh www-data" >> /etc/cron.d/seeddms
fi

if [ -n "$CRON_BACKUP" ]; then
	   echo "$CRON_BACKUP su -s /bin/bash -c /usr/local/bin/seeddms-generate-backup.sh www-data" >> /etc/cron.d/seeddms
fi

if [ -e /etc/cron.d/seeddms ]; then
		crontab /etc/cron.d/seeddms
fi

rm -f /var/run/cron*
cron

cp /var/templates/seeddms/conf/settings.xml /var/www/seeddms/conf/settings.xml
set +e
params="$(env | grep -io "SET_configuration_")"
for param in $params; do
	xpath="$( echo "$param" | grep -io "SET_configuration_[^=]*" | sed 's/SET_//g' | sed 's|__|/@|g' | sed 's|_|/|g' )"
	value="$( echo "$param" | grep -io "=.*" | sed 's/^=//g')"
	xmlstarlet ed -L -u "$xpath" -v "$value" /var/www/seeddms/conf/settings.xml
done

params="$(env | grep -io "DELETE_configuration_")"
for param in $params; do
	xpath="$( echo "$param" | grep -io "DELETE_configuration_[^=]*" | sed 's/SET_//g' | sed 's|__|/@|g' | sed 's|_|/|g' )"
	xmlstarlet ed -L -d "$xpath" /var/www/seeddms/conf/settings.xml 
done
set -e
. /usr/local/bin/docker-php-entrypoint

for file in /var/seeeddms/hooks/*; do
  if [ -x $file ]; then
    $file
  fi
done

apachectl -D FOREGROUND
