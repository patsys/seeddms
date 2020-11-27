#!/bin/bash
set -e
xmlstarlet ed -L -u "/configuration/system/server/@rootDir" -v "/var/www/seeddms/seeddms/" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/server/@httpRoot" -v "/" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/server/@contentDir" -v "/var/www/seeddms/data/content/" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/server/@stagingDir" -v "/var/www/seeddms/data/staging/" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/server/@backupDir" -v "/var/www/seeddms/data/backup/" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/server/@cacheDir" -v "/var/www/seeddms/data/cache/" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/server/@dropFolderDir" -v "/var/www/seeddms/data/drop/" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/server/@luceneDir" -v "/var/www/seeddms/data/lucene/" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/database/@dbDriver" -v "sqlite" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/database/@dbHostname" -v "localhost" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/database/@dbDatabase" -v "/var/www/seeddms/data/content.db" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/database/@dbUesr" -v "seeddms" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/database/@dbPassword" -v "seeddms" /var/templates/seeddms/conf/settings.xml
xmlstarlet ed -L -u "/configuration/system/database/@doNotCheckVersion" -v "false" /var/templates/seeddms/conf/settings.xml

