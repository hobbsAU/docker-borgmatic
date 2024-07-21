#Borgbackup Dockerfile
FROM alpine:edge
MAINTAINER Adrian Hobbs <adrianhobbs@gmail.com>

#Buldtime environment
ARG PACKAGE="tzdata python3 openssh-client borgbackup borgmatic"

# Install package using --no-cache to update index and remove unwanted files
RUN 	\
    apk add --no-cache --upgrade apk-tools && \
    apk upgrade --no-cache && \
    apk add ${PACKAGE}  && \
    rm -rf /var/cache/apk/*

#Runtime environment
WORKDIR /backup

VOLUME /root/.config/borg
VOLUME /root/.cache/borg
VOLUME /root/.config/borgmatic
VOLUME /root/.ssh
VOLUME /backup

ENTRYPOINT ["/usr/bin/borgmatic"]

