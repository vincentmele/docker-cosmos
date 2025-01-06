#FROM gcr.io/distroless/static-debian12
FROM debian:12-slim

ENV VERSION v19.1.0-linux-amd64
ENV PACKAGES wget supervisor lz4 gzip

ENV GAIAD_HOME=/.gaiad


RUN apt-get update && apt-get install -y ${PACKAGES} && apt-get clean && apt-get autoclean
# Install ca-certificates
#RUN apk add --no-cache --update ca-certificates py3-setuptools supervisor wget lz4 gzip

# Temp directory for copying binaries
RUN mkdir -p /tmp/bin
WORKDIR /tmp/bin

ADD https://github.com/cosmos/gaia/releases/download/v19.1.0/gaiad-${VERSION} /tmp/bin/gaiad

RUN install -m 0755 -o root -g root -t /usr/local/bin gaiad

# Remove temp files
RUN rm -r /tmp/bin

# Add supervisor configuration files
RUN mkdir -p /etc/supervisor/conf.d/
COPY /supervisor/supervisord.conf /etc/supervisor/supervisord.conf 
COPY /supervisor/conf.d/* /etc/supervisor/conf.d/


WORKDIR $GAIAD_HOME

# Expose ports
EXPOSE 26656 26657 26658
EXPOSE 1317

# Add entrypoint script
COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod u+x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

STOPSIGNAL SIGINT
