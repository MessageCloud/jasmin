#!/bin/bash
set -e

#echo 'Starting RabbitMQ'
#/etc/init.d/rabbitmq-server start
#rabbitmqctl add_user $(echo $RABBITMQ_USERNAME) $(echo $RABBITMQ_PASSWORD)
#rabbitmqctl set_user_tags $(echo $RABBITMQ_USERNAME) administrator
#rabbitmqctl set_permissions -p / $(echo $RABBITMQ_USERNAME) ".*" ".*" ".*"
#rabbitmqctl delete_user guest
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
