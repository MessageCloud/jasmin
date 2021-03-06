What is Jasmin?
===============

Jasmin is a very complete open source SMS Gateway with many enterprise-class features such as:

* SMPP Client / Server
* HTTP Client / Server
* Console-based configuration, no service restart required
* Based on AMQP broker for store&forward mechanisms and other queuing systems
* Using Redis for in-memory DLR tracking and billing
* Advanced message routing/filtering (Simple, Roundrobin, Failover, HLR lookup, Leastcost ...)
* Web and console ui for management
* Supports Unicode (UTF-8) for sending out multilingual SMS
* Supports easy creation and sending of specialized/binary SMS like mono Ringtones, WAP Push, Vcards
* Supports concatenated SMS strings (long SMS)
* Jasmin relies heavily on message queuing through message brokers (Using AMQP), it is designed for performance, high traffic loads and full in-memory execution.

![logo](https://raw.githubusercontent.com/jookies/jasmin/master/misc/doc/sources/_static/jasmin-logo-small.png)

How to use this image
=====================

Run in daemon mode:

```console
$ docker run -d -p 2775:2775 -p 8990:8990 -p 1401:1401 -p 6379:6379 -p 15672:15672 -p 8000:8000 -p 8001:8001 --name docker_messagecloud_jasmin messagecloud/jasmin:latest
```

Start/stop daemon:

```console
$ docker stop docker_messagecloud_jasmin_1
$ docker start docker_messagecloud_jasmin_1
```

What is included
================

All containers communicate across a dedicated Docker network.  They also use dedicated Docker volumes for persistent storage, accessible from the host at ```/var/lib/docker/volumes/```

When using the standard docker-compose.yml:
-------------------------------------------

1. Jasmin container -  Jasmin SMS Gateway, Jasmin API and Jasmin Web Panel
2. Redis container - Redis Key/Value store for pre-DLR messages and post-DLR messages
3. RabbitMQ container - All message broker queues for message processing
4. MySQL - For message logging

When using the docker-compose-HA-RabbitMQ.yml for remote RabbitMQ message broker usage: 
-------------------------------------------

1. Jasmin container -  Jasmin SMS Gateway, Jasmin API and Jasmin Web Panel
2. Redis container - Redis Key/Value store for pre-DLR messages and post-DLR messages
3. MySQL - For message logging


License
=======

View [license information](https://raw.githubusercontent.com/jookies/jasmin/master/LICENSE) for the software contained in this image.

Supported Docker versions
=========================

This image is officially supported on Docker version 1.9.0.

Support for older versions (down to 1.6) is provided on a best-effort basis.

Please see [the Docker installation documentation](https://docs.docker.com/installation/) for details on how to upgrade your Docker daemon.

Documentation
=============

Documentation for using Jasmin's docker image is located [here](http://docs.jasminsms.com/en/latest/installation/index.html#docker).

Issues and support
------------------

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/jookies/jasmin/issues).

You can also reach out for support [here](https://groups.google.com/forum/#!forum/jasmin-sms-gateway) or by dropping a message to support [at] jookies [dot] net.

Usage
-----

1. Change directory to the docker directory

2. Pull the JasminWebPanel and jasmin-api repositories into the docker directory

```
https://github.com/tarikogut/JasminWebPanel.git
https://github.com/jookies/jasmin-api.git
```

3. Change the jasmin-api port number to 8001 by editing ```jasmin-api/jasmin_api/run_cherrypy.py```

4. Create the jasmin-api ```jasmin-api/jasmin_api/jasmin_api/local_settings.py``` file and only edit the ```SECRET_KEY``` with any random alphanumeric string

```
TELNET_HOST = os.environ.get('JASMIN_HOST', 'jasmin')
TELNET_PORT = int(os.environ.get('JASMIN_PORT', 8990))
TELNET_USERNAME = os.environ.get('JASMIN_USERNAME', 'jcliadmin')
TELNET_PW = os.environ.get('JASMIN_PASSWORD', 'jclipwd')  # no alternative storing as plain text
DEBUG = False
SECRET_KEY = '<input a random alphanumeric string of characters>'
```

5. Copy the .env.example to .env

6. Make changes to the .env

7a. To build and run with a dedicated RabbitMQ container:

```docker-compose up --build -d```

7b. To build and run without a dedicated RabbitMQ container and to use a remote RabbitMQ cluster:

```docker-compose -f docker-compose-HA-RabbitMQ.yml up --build -d```

This will use the Docker file ```Dockerfile-HA-RabbitMQ``` that allows for vhost specification and to apply the HA policy "ha-jasmin" to all exchanges and queues.

When using a remote HA Rabbit Cluster you MUST use an alternative Virtual Host to '/' and set in the .env file the MYSQL_HOST=172.20.0.3.

CentOS host issues
------------------

If you are running CentOS as the host OS, Docker has issues resolving DNS.

To fix external DNS resolves if the docker container has issues resolving when running apt-get update:
1. Edit the ```/etc/sysconfig/docker``` file and add ```--dns=<nameserver address>``` to the ```OPTIONS=''``` section.
2. Restart the Docker daemon.

To fix RabbitMQ startup issues caused by problems resolving the local hostname:
Edit the ```/etc/hosts``` file and include the hostname for the 127.0.0.1 declaration:
```127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 jasmin jasmin.example.com```
