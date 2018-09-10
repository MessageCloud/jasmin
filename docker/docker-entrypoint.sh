#!/bin/bash
set -e

echo 'Starting supervisor'
/etc/init.d/supervisor start
echo 'Starting Jasmin API'
/jasmin-api/jasmin_api/run_cherrypy.py &
echo 'Starting Jasmin Web UI'
/webui/bin/python /JasminWebPanel/manage.py runserver 0.0.0.0:8000 &

echo 'Cleaning lock files'
rm -f /tmp/*.lock

if [ "$2" = "--enable-interceptor-client" ]; then
  echo 'Starting interceptord'
  interceptord.py &
fi

echo 'Starting jasmind'
/usr/bin/python /usr/local/bin/jasmind.py --enable-interceptor-client --enable-dlr-thrower --enable-dlr-lookup -u $JASMIN_USERNAME -p $JASMIN_PASSWORD
exec "$@"
