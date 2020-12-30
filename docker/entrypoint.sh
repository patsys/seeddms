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
params="$(env | grep -io "SET_configuration_.*")"
for param in $params; do
	xpath="$( echo "$param" | grep -io "SET_configuration_[^=]*" | sed 's/SET_//g' | sed 's|__|/@|g' | sed 's|_|/|g' )"
	value="$( echo "$param" | grep -io "=.*" | sed 's/^=//g')"
	xmlstarlet ed -L -u "$xpath" -v "$value" /var/www/seeddms/conf/settings.xml
done

params="$(env | grep -io "DELETE_configuration_.*")"
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

mkdir -p /var/www/seeddms/store/{staging,lucene,content,backup,drop}
if [ ! -f /var/www/seeddms/store/content.db ]; then
  cp /var/www/seeddms/data/content.db /var/www/seeddms/store/content.db
fi
chown -R www-data:www-data /var/www/seeddms
touch /var/www/seeddms/conf/ENABLE_INSTALL_TOOL
apachectl start
sleep 5
params="$(xmlstarlet sel -T -t -m '//form//input[@name and @value]' -v "concat(\" -F '\",@name,\"=\",@value,\"'\")" <<<"$(curl http://127.0.0.1/install/install.php | xmlstarlet fo -H -R )")"
eval $(echo curl -k -X POST "$params" -F "createDatabase=on" http://127.0.0.1/install/install.php)
sleep 5
eval $(echo curl -k -X POST "$params"  http://127.0.0.1/install/install.php)
rm /var/www/seeddms/conf/ENABLE_INSTALL_TOOL
if [ -n "$ADMIN_INITIAL_PASSWORD" ]; then
  tmp="$(mktemp /tmp/cookie.XXXXXX)"
  if curl -f -c $tmp -k -X POST "http://127.0.0.1/restapi/index.php/login" -H  "accept: application/json" -H  "Content-Type: application/x-www-form-urlencoded" -d "user=admin" -d "pass=admin"; then
     if curl -f -b $tmp -k -X PUT "http://127.0.0.1/restapi/index.php/users/1/password" -H "Content-Type: application/x-www-form-urlencoded" -H  "accept: application/json" --data-urlencode "password=$(echo -n "$ADMIN_INITIAL_PASSWORD" | md5sum | awk '{print $1}')"; then
       echo "password change"
       rm $tmp
     else
       echo "password change failed" >&2
       rm $tmp
       exit 1
     fi
  fi
unset ADMIN_INITIAL_PASSWORD
fi
apachectl stop
sleep 2
apachectl -D FOREGROUND
