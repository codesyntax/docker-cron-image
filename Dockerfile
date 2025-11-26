FROM alpine:latest
RUN apk add --no-cache bash curl cronie docker-cli

# Copy and ensure correct permissions
COPY crontab.txt /crontab.txt
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN mkdir -p /root/.cache

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]