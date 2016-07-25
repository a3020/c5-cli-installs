#!/usr/bin/env bash

echo "## Start installation"

if [ "$1" != "" ]; then
	if [ -f "_config/$1.cfg" ]; then
		echo "## Parse $1 config file"
		source "_config/$1.cfg"
	else 
		echo "## Config file '$1.cfg' is missing"
		exit;
	fi
else
	if [ -f "_config/latest.cfg" ]; then
		source "_config/latest.cfg"	
	else
		echo "## Config file 'latest.cfg' is missing"
		exit
	fi
fi

if [ -d $FOLDER_NAME ]; then
	echo "## Delete old folder"
	rm -Rf $FOLDER_NAME
fi

mkdir $FOLDER_NAME

if [ ! -d "_cache" ]; then
	mkdir _cache
fi

if [ ! -f "_cache/${C5_VERSION}.zip" ]; then
	echo "## Download C5"
	wget cache -q $C5_DOWNLOAD  -O "_cache/${C5_VERSION}.zip"
fi

echo "## Unzip C5"
unzip -q -d _cache "_cache/$C5_VERSION.zip"
cd $FOLDER_NAME
mv ../_cache/concrete5.*/* .
rm -Rf ../_cache/concrete5*

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
concrete/bin/concrete5 c5:config set concrete.misc.seen_introduction true

echo "## Done"