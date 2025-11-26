FROM alpine:latest
RUN apk add --no-cache bash curl cronie docker-cli

# Kopiatu eta ziurtatu baimenak egokiak direla
COPY crontab.txt /etc/crontabs/root
RUN chmod 0644 /etc/crontabs/root

# Alpine-n crond zuzenean deitu dezakegu
CMD ["crond", "-f", "-l", "2"]