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

. /usr/local/bin/docker-php-entrypoint


