FROM debian:jessie

MAINTAINER Jookies LTD <jasmin@jookies.net>

ARG JASMIN_VERSION
ARG JASMIN_USERNAME
ARG JASMIN_PASSWORD
ARG JASMIN_PASSWORD_MD5
ARG JASMIN_PORT
ARG RABBITMQ_USERNAME
ARG RABBITMQ_PASSWORD
ARG RABBITMQ_HOST
ARG RABBITMQ_VHOST
ARG JASMIN_API_USERNAME
ARG JASMIN_API_PASSWORD
ARG JASMIN_WEBUI_USERNAME
ARG JASMIN_WEBUI_PASSWORD

ENV JASMIN_VERSION "${JASMIN_VERSION}"
ENV JASMIN_USERNAME "${JASMIN_USERNAME}"
ENV JASMIN_PASSWORD "${JASMIN_PASSWORD}"
ENV JASMIN_PASSWORD_MD5 "${JASMIN_PASSWORD_MD5}"
ENV RABBITMQ_USERNAME "${RABBITMQ_USERNAME}"
ENV RABBITMQ_PASSWORD "${RABBITMQ_PASSWORD}"
ENV RABBITMQ_HOST "${RABBITMQ_HOST}"
ENV RABBITMQ_VHOST "${RABBITMQ_VHOST}"
ENV JASMIN_API_USERNAME "${JASMIN_API_USERNAME}"
ENV JASMIN_API_PASSWORD "${JASMIN_API_PASSWORD}"
ENV JASMIN_WEBUI_USERNAME "${JASMIN_WEBUI_USERNAME}"
ENV JASMIN_WEBUI_PASSWORD "${JASMIN_WEBUI_PASSWORD}"

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r jasmin \
&&  useradd -r -g jasmin jasmin

# Install requirements
RUN apt-get update && apt-get install -y \
    python2.7 \
    python-pip \
    python-dev \
    libffi-dev \
    libssl-dev \
    redis-server \
    supervisor \
    telnet \
    nano \
    virtualenv \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/*

# Install Jasmin SMS gateway
RUN mkdir -p /etc/jasmin/resource \
    /etc/jasmin/store \
    /var/log/jasmin \
&&  chown jasmin:jasmin /etc/jasmin/store \
    /var/log/jasmin \
&&  pip install --pre jasmin=="$JASMIN_VERSION"

# Change Jasmin configuration
RUN sed -i '/\[jcli\]/a bind=0.0.0.0' /etc/jasmin/jasmin.cfg \
&&  sed -i '/\[jcli\]/a admin_username='"$JASMIN_USERNAME" /etc/jasmin/jasmin.cfg \
&&  sed -i '/\[jcli\]/a admin_password='"$JASMIN_PASSWORD_MD5" /etc/jasmin/jasmin.cfg \
&&  sed -i '/\[jcli\]/a port='"$JASMIN_PORT" /etc/jasmin/jasmin.cfg \
&&  sed -i '/\[smpp-server\]/a dlr_expiry=259200' /etc/jasmin/jasmin.cfg \
&&  sed -i '/\[redis-client\]/a host=172.20.0.2' /etc/jasmin/jasmin.cfg \
&&  sed -i '/\[amqp-broker\]/a username='"$RABBITMQ_USERNAME" /etc/jasmin/jasmin.cfg \
&&  sed -i '/\[amqp-broker\]/a password='"$RABBITMQ_PASSWORD" /etc/jasmin/jasmin.cfg \
&&  sed -i '/\[amqp-broker\]/a host='"$RABBITMQ_HOST" /etc/jasmin/jasmin.cfg \
&&  sed -i '/\[amqp-broker\]/a vhost='"$RABBITMQ_VHOST" /etc/jasmin/jasmin.cfg \
&&  sed -i '/\[amqp-broker\]/a heartbeat=15' /etc/jasmin/jasmin.cfg

EXPOSE 2775 "$JASMIN_PORT" 1401 8000 8001
COPY ./docker/jasmin-api /jasmin-api
COPY ./docker/JasminWebPanel /JasminWebPanel

# Install the WebUI and API
RUN easy_install -U pip && apt-get install --reinstall python-pip \
&&  pip install -r /jasmin-api/requirements.txt \
&&  /jasmin-api/jasmin_api/manage.py migrate \
&&  echo "from django.contrib.auth.models import User; User.objects.create_superuser('$JASMIN_API_USERNAME', '', '$JASMIN_API_PASSWORD')" | /jasmin-api/jasmin_api/manage.py shell \
&&  echo "yes" | /jasmin-api/jasmin_api/manage.py collectstatic \
&&  virtualenv /webui \
&&  /webui/bin/pip install -r /JasminWebPanel/requirements.pip \
&&  /webui/bin/python /JasminWebPanel/manage.py migrate \
&&  echo "from django.contrib.auth.models import User; User.objects.create_superuser('$JASMIN_WEBUI_USERNAME', '', '$JASMIN_WEBUI_PASSWORD')" | /webui/bin/python /JasminWebPanel/manage.py shell \
&&  echo "yes" | /webui/bin/python /JasminWebPanel/manage.py collectstatic

ADD ./jasmin /usr/local/lib/python2.7/dist-packages/jasmin/

COPY /docker/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
# Notes:
# - jasmind is started with native dlr-thrower and dlr-lookup threads instead of standalone processes
# - restapi (0.9rc16+) is not started in this docker configuration
