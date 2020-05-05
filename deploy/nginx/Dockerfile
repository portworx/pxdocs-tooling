FROM nginx
MAINTAINER kaiyadavenport@gmail.com
COPY ./${NGINX_CONFIG_FILE} /etc/nginx/nginx.conf
COPY ./pxdocs-directs.conf /etc/nginx/pxdocs-directs.conf
COPY ./hugo_public /www
