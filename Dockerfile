#Borgbackup Dockerfile
FROM alpine:edge
MAINTAINER Adrian Hobbs <adrianhobbs@gmail.com>

#Buldtime environment
ARG PACKAGE="tzdata python3 openssh-client alpine-sdk openssl-dev python3-dev lz4-dev acl-dev linux-headers"
ARG BORGMATIC_VERSION="borgmatic"
ARG BORG_VERSION="borgbackup"

# Install package using --no-cache to update index and remove unwanted files
RUN 	\
    apk add --no-cache --upgrade apk-tools && \
    apk upgrade --no-cache && \
    apk add ${PACKAGE}  && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [ ! -e /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    pip3 install --upgrade ${BORG_VERSION} ${BORGMATIC_VERSION} && \
    rm -r /root/.cache && \
    apk del alpine-sdk python3-dev linux-headers && \
    rm -rf /var/cache/apk/*

#Runtime environment
WORKDIR /backup

VOLUME /root/.config/borg
VOLUME /root/.cache/borg
VOLUME /root/.config/borgmatic
VOLUME /root/.ssh
VOLUME /backup

CMD ["/usr/bin/borgmatic"]

