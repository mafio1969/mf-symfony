FROM mafio69/phpdebian:latest

USER root
WORKDIR /
ENV DEBIAN_FRONTEND=noninteractive \
  APP_ENV=${APP_ENV:-prod} \
  DISPLAY_ERROR=${DISPLAY_ERROR:-off} \
  XDEBUG_MODE=${XDEBUG_MODE:-off} \
  PHP_DATE_TIMEZONE=${PHP_DATE_TIMEZONE:-Europe/Warsaw}

RUN  mkdir -p /var/log/cron/ \
        && ln -sf /var/log/nginx/project_access.log stdout \
    	&& mkdir -p /usr/share/nginx/logs/ \
    	&& mkdir -p /var/log/nginx/ \
    	&& mkdir -p /var/lib/nginx/body \
    	&& chmod 777 -R /var/lib/nginx/ \
    	&& chmod 777 -R /var/log/ \
        && usermod -a -G docker root && adduser \
       --system \
       --shell /bin/bash \
       --disabled-password \
       --home /home/docker \
       docker \
       && usermod -a -G docker root \
       && usermod -a -G docker docker \
       && rm -f /etc/supervisor/conf.d/supervisord.conf \
       && touch -c /var/log/cron/cron.log \
       && touch -c /usr/share/nginx/logs/error.log

COPY container.d/cron-task /etc/cron.d/crontask
COPY container.d/custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY container.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY container.d/supervisord-main.conf /etc/supervisord.conf
COPY container.d/nginx/nginx.conf /etc/nginx/nginx.conf
COPY container.d/nginx/enabled-symfony.conf /etc/nginx/conf.d/enabled-symfony.conf
COPY --chown=1000:docker /main /main

WORKDIR /main
RUN rm -Rf /main

STOPSIGNAL SIGQUIT
EXPOSE 8080
CMD ["supervisord", "-n"]
