FROM alpine:latest
RUN apk add --no-cache bash curl cronie docker-cli

# Kopiatu eta ziurtatu baimenak egokiak direla
COPY crontab.txt /crontab.txt
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN mkdir -p /root/.cache

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]