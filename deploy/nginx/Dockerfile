FROM nginx
MAINTAINER kaiyadavenport@gmail.com
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./pxdocs-directs.conf /etc/nginx/pxdocs-directs.conf
COPY ./px-backup-redirects.conf /etc/nginx/px-backup-redirects.conf
COPY ./px-enterprise-redirects.conf /etc/nginx/px-enterprise-redirects.conf
COPY ./px-central-redirects.conf /etc/nginx/px-central-redirects.conf
COPY ./hugo_public /www
ARG NGINX_REDIRECTS_FILE
RUN sed "s/\${NGINX_REDIRECTS_FILE}/$NGINX_REDIRECTS_FILE/g" /etc/nginx/nginx.conf > temp.txt && rm -f /etc/nginx/nginx.conf && mv temp.txt /etc/nginx/nginx.conf
