FROM nginx
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

COPY ./nginx/proxy.conf /etc/nginx/includes/proxy.conf