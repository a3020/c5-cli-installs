#!/usr/bin/env bash

echo "## Start"

echo "## Read global config"
source config.cfg

C5_VERSION="5758"
C5_DOWNLOAD="https://www.concrete5.org/download_file/-/view/89071/"

if [ -d $VERSION ]; then
	echo "## Delete old folder"
	rm -Rf $C5_VERSION
fi

mkdir $C5_VERSION

if [ ! -d "cache" ]; then
	mkdir cache
fi

if [ ! -f "cache/${C5_VERSION}.zip" ]; then
	echo "## Download C5"
	wget cache -q $C5_DOWNLOAD  -O "cache/${C5_VERSION}.zip"
fi

echo "## Unzip C5"
unzip -q -d cache "cache/$C5_VERSION.zip"
cd $C5_VERSION
mv ../cache/concrete5.*/* .
rm -Rf ../cache/concrete5*

chmod +x concrete/bin/concrete5

echo '## Create DB'
mysql -u $DB_USER -p$DB_PASS -h $DB_HOST --execute="DROP DATABASE IF EXISTS ${DB_PREFIX}${DB_NAME}; CREATE DATABASE ${DB_PREFIX}${DB_NAME}"

echo '## Install C5'
concrete/bin/concrete5 c5:install --db-server=$DB_HOST --db-username=$DB_USER --db-password=$DB_PASS --db-database=${DB_PREFIX}${DB_NAME} \
		--admin-email=admin@example.com --admin-password=admin \
			--starting-point=elemental_blank

echo '## Write .htaccess'
cat > .htaccess <<EOL
# -- concrete5 urls start --
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME}/index.html !-f
RewriteCond %{REQUEST_FILENAME}/index.php !-f
RewriteRule . index.php [L]
</IfModule>
# -- concrete5 urls end --
EOL

echo '## Write C5 config values'
concrete/bin/concrete5 c5:config set concrete.debug.detail debug
concrete/bin/concrete5 c5:config set concrete.debug.display_errors true
concrete/bin/concrete5 c5:config set concrete.misc.seen_introduction tru

echo "## Done"
