FROM debian:jessie

MAINTAINER Jookies LTD <jasmin@jookies.net>

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r jasmin && useradd -r -g jasmin jasmin

ARG JASMIN_VERSION
ARG JASMIN_USERNAME
ARG JASMIN_PASSWORD
ARG JASMIN_PASSWORD_MD5
ARG RABBITMQ_USERNAME
ARG RABBITMQ_PASSWORD
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
ENV JASMIN_API_USERNAME "${JASMIN_API_USERNAME}"
ENV JASMIN_API_PASSWORD "${JASMIN_API_PASSWORD}"
ENV JASMIN_WEBUI_USERNAME "${JASMIN_WEBUI_USERNAME}"
ENV JASMIN_WEBUI_PASSWORD "${JASMIN_WEBUI_PASSWORD}"

# Install requirements
RUN apt-get update && apt-get install -y \
    python2.7 \
    python-pip \
    python-dev \
    libffi-dev \
    libssl-dev \
    rabbitmq-server \
    redis-server \
    supervisor \
    telnet \
    nano \
    virtualenv \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Jasmin SMS gateway
RUN mkdir -p /etc/jasmin/resource \
    /etc/jasmin/store \
    /var/log/jasmin \
  && chown jasmin:jasmin /etc/jasmin/store \
    /var/log/jasmin \
  && pip install --pre jasmin=="$JASMIN_VERSION"

# Change binding host for jcli
RUN sed -i '/\[jcli\]/a bind=0.0.0.0' /etc/jasmin/jasmin.cfg
RUN sed -i '/\[jcli\]/a admin_password='"$JASMIN_PASSWORD_MD5" /etc/jasmin/jasmin.cfg
RUN sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
RUN sed -i '/\[amqp-broker\]/a username='"$RABBITMQ_USERNAME" /etc/jasmin/jasmin.cfg
RUN sed -i '/\[amqp-broker\]/a password='"$RABBITMQ_PASSWORD" /etc/jasmin/jasmin.cfg
RUN rabbitmq-plugins enable rabbitmq_management
RUN echo 0 > /temp

EXPOSE 2775 8990 1401 6379 15672 8000 8001
VOLUME ["/var/log/jasmin", "/etc/jasmin", "/etc/jasmin/store"]
COPY ./jasmin-api /jasmin-api
COPY ./JasminWebPanel /JasminWebPanel
RUN easy_install -U pip && apt-get install --reinstall python-pip
RUN pip install -r /jasmin-api/requirements.txt
RUN /jasmin-api/jasmin_api/manage.py migrate
RUN echo "from django.contrib.auth.models import User; User.objects.create_superuser('$JASMIN_API_USERNAME', '', '$JASMIN_API_PASSWORD')" | /jasmin-api/jasmin_api/manage.py shell
RUN echo "yes" | /jasmin-api/jasmin_api/manage.py collectstatic

RUN virtualenv /webui
RUN /webui/bin/pip install -r /JasminWebPanel/requirements.pip
RUN /webui/bin/python /JasminWebPanel/manage.py migrate
RUN echo "from django.contrib.auth.models import User; User.objects.create_superuser('$JASMIN_WEBUI_USERNAME', '', '$JASMIN_WEBUI_PASSWORD')" | /webui/bin/python /JasminWebPanel/manage.py shell
RUN echo "yes" | /webui/bin/python /JasminWebPanel/manage.py collectstatic

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["jasmind.py", "--enable-interceptor-client", "--enable-dlr-thrower", "--enable-dlr-lookup", "-u", "$JASMIN_USERNAME", "-p", "$JASMIN_PASSWORD"]
# Notes:
# - jasmind is started with native dlr-thrower and dlr-lookup threads instead of standalone processes
# - restapi (0.9rc16+) is not started in this docker configuration
