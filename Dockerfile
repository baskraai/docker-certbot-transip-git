FROM baskraai/certbot-dns-transip
MAINTAINER Bas Kraai <bas@kraai.email>

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
