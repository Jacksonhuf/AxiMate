FROM nginx:alpine

RUN apk add --no-cache apache2-utils

COPY deploy/gateway/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
