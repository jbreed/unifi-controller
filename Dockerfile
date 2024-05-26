FROM alpine:3.20

LABEL maintainer="jbreed"

# Environment settings
ENV UNIFI_BRANCH="stable"
ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV PATH=$JAVA_HOME/bin:$PATH

# Install necessary packages and Java
RUN apk update && apk add --no-cache \
    openjdk17-jre \
    jsvc \
    logrotate \
    unzip \
    curl \
    bash \
    netcat-openbsd \
    openssl

# Install Unifi
RUN echo "**** install unifi ****" && \
    : ${UNIFI_VERSION:=$(curl -sX GET https://dl.ui.com/unifi/debian/dists/${UNIFI_BRANCH}/ubiquiti/binary-amd64/Packages | grep -A 7 -m 1 'Package: unifi' | awk -F ': ' '/Version/{print $2;exit}' | awk -F '-' '{print $1}')} && \
    mkdir -p /app && \
    curl -o /tmp/unifi.zip -L "https://dl.ui.com/unifi/${UNIFI_VERSION}/UniFi.unix.zip" && \
    unzip /tmp/unifi.zip -d /app && \
    mv /app/UniFi /app/unifi && \
    echo "**** cleanup ****" && \
    rm -rf /tmp/* /var/cache/apk/*

# Configuration File
COPY defaults/ /defaults/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Set permissions and make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chown -R 25000:25000 /app/unifi /config && \
    chmod -R 777 /app/unifi /config

# Set working directory and mount volume
WORKDIR /app/unifi
VOLUME /config

# Expose necessary ports
EXPOSE 8080 8443 8843 8880

# Command to run the application
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]