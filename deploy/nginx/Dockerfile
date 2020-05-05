FROM nginx
MAINTAINER kaiyadavenport@gmail.com
ARG NGINX_CONFIG_FILE
COPY ./$NGINX_CONFIG_FILE /etc/nginx/nginx.conf
COPY ./pxdocs-directs.conf /etc/nginx/pxdocs-directs.conf
COPY ./hugo_public /www
