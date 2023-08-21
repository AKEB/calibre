FROM ubuntu:23.04

ENV TZ=Europe/Moscow

WORKDIR /opt/calibre/

USER root

RUN apt-get clean && apt-get dist-upgrade \
	&& apt-get update -y --allow-insecure-repositories

RUN apt-get install -y --allow-unauthenticated \
	libfontconfig libgl1-mesa-glx libegl1 libopengl0 libxkbcommon-dev cron \
	mc iputils-ping curl ca-certificates wget nano python3

COPY ./book.epub /root/
COPY ./calibre/users.sqlite /root/calibre/
COPY ./calibre-cron /etc/cron.d/

RUN chmod 0644 /etc/cron.d/calibre-cron

RUN wget https://download.calibre-ebook.com/linux-installer.sh \
	&& chmod +x ./linux-installer.sh \
	&& ./linux-installer.sh \
	&& mkdir /root/calibre-library \
	&& calibredb add /root/*.epub --with-library /root/calibre-library/

RUN crontab /etc/cron.d/calibre-cron
# Create the log file to be able to run tail
RUN touch /var/log/cron.log

CMD cron; /opt/calibre/calibre-server /root/calibre-library --enable-local-write --userdb /root/calibre/users.sqlite --enable-auth

# CMD ["/bin/bash"]

EXPOSE 8080