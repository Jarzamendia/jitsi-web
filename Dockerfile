FROM node:10 as build

WORKDIR /app

COPY . /app

RUN npm install

RUN make

RUN make source-package

FROM jitsi/base

COPY rootfs/ /

WORKDIR /usr/share

RUN \
	apt-dpkg-wrap apt-get update && \
	apt-dpkg-wrap apt-get install -y cron nginx-extras bzip2 && \
	apt-dpkg-wrap apt-get install -y -t stretch-backports certbot && \
	apt-cleanup && \
	rm -f /etc/nginx/conf.d/default.conf && \
	rm -rf /tmp/pkg /var/cache/apt

COPY --from=build /app/jitsi-meet.tar.bz2 /usr/share/

RUN bunzip2 jitsi-meet.tar.bz2 \
    && tar xvf jitsi-meet.tar \
	&& rm jitsi-meet.tar \
    && mv /usr/share/jitsi-meet/interface_config.js /defaults

EXPOSE 80 443

VOLUME ["/config", "/etc/letsencrypt", "/usr/share/jitsi-meet/transcripts"]