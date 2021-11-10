FROM mafio69/phpdebian:latest


USER root
WORKDIR /
ENV DEBIAN_FRONTEND=noninteractive \
  APP_ENV=${APP_ENV:-dev} \
  XDEBUG_AVAILABLE=${XDEBUG_AVAILABLE:-off}
COPY container.d/cron-task /etc/cron.d/crontask
COPY container.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY container.d/nginx/nginx.conf /etc/nginx/nginx.conf
COPY container.d/nginx/enabled-symfony.conf /etc/nginx/conf.d/enabled-symfony.conf
RUN  mkdir -p /var/log/cron/ \
        && ln -sf /main/var/log/local.log stdout\
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
# COPY container.d/xdebug-on.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY container.d/cron-task /etc/cron.d/crontask
COPY container.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY container.d/supervisord-main.conf /etc/supervisord.conf
COPY container.d/nginx/nginx.conf /etc/nginx/nginx.conf
COPY container.d/nginx/enabled-symfony.conf /etc/nginx/conf.d/enabled-symfony.conf
COPY --chown=docker:docker /main /main
WORKDIR /main
STOPSIGNAL SIGQUIT
EXPOSE 8080 9000
CMD ["supervisord", "-n"]



