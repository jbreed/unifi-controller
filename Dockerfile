FROM ubuntu:24.04

LABEL maintainer="jbreed"

# Environment settings
ENV UNIFI_BRANCH="stable"
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install necessary packages and Java
RUN apt-get update -y && apt-get install -y \
    openjdk-17-jre \
    logrotate \
    unzip \
    curl \
    bash \
    openssl \
    libc6 \
    systemd \
    && apt-get remove --purge -y openjdk-11-* openjdk-8-* && apt-get autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Unifi
RUN echo "**** install unifi ****" && \
    : ${UNIFI_VERSION:=$(curl -sX GET https://dl.ui.com/unifi/debian/dists/${UNIFI_BRANCH}/ubiquiti/binary-amd64/Packages | grep -A 7 -m 1 'Package: unifi' | awk -F ': ' '/Version/{print $2;exit}' | awk -F '-' '{print $1}')} && \
    mkdir -p /app && \
    curl -o /tmp/unifi.zip -L "https://dl.ui.com/unifi/${UNIFI_VERSION}/UniFi.unix.zip" && \
    unzip /tmp/unifi.zip -d /app && \
    mv /app/UniFi /app/unifi

# Update dom4j (vuln patch)
RUN curl -L -o /tmp/dom4j-2.1.4.jar https://repo1.maven.org/maven2/org/dom4j/dom4j/2.1.4/dom4j-2.1.4.jar && \
    find /app/unifi -name 'dom4j-*.jar' -exec rm {} \; && \
    cp /tmp/dom4j-2.1.4.jar /app/unifi/lib/

# # Update OWASP Java HTML Sanitizer (vuln patch)
# RUN curl -L -o /tmp/owasp-java-html-sanitizer-20211018.2.jar https://repo1.maven.org/maven2/com/googlecode/owasp-java-html-sanitizer/owasp-java-html-sanitizer/20211018.2/owasp-java-html-sanitizer-20211018.2.jar && \
#     find /app/unifi -name 'owasp-java-html-sanitizer-*.jar' -exec rm {} \; && \
#     cp /tmp/owasp-java-html-sanitizer-20211018.2.jar /app/unifi/lib/

# Cleanup
RUN echo "**** cleanup ****" && \
    rm -rf /tmp/* /var/cache/apk/*

# Configuration File
COPY defaults/ /defaults/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Set permissions and make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chown -R 2000:2000 /app/unifi /defaults && \
    chmod -R 777 /app/unifi /defaults

# Set working directory and mount volume
WORKDIR /app/unifi
VOLUME /config

# Expose necessary ports
EXPOSE 8080 8443 8843 8880

# Command to run the application
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
