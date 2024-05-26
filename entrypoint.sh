#!/bin/bash
echo "Starting..."

mkdir -p /config/{data,logs}

echo "Creating sym links..."
# Create sym links for data and logs if they don't already exist
if [ ! -L /app/unifi/data ]; then
    ln -s /config/data /app/unifi/data
fi

if [ ! -L /app/unifi/logs ]; then
    ln -s /config/logs /app/unifi/logs
fi

# Update system.properties file
# update config file with mongo connection details
echo "Configuring system.properties for MongoDB..."
if [[ ! -e /config/data/system.properties ]]; then
    if [[ -z "${MONGO_HOST}" ]]; then
        echo "*** No MONGO_HOST set, cannot configure database settings. ***"
        exit 1
    else
        echo "*** Waiting for MONGO_HOST ${MONGO_HOST} to be reachable. ***"
        DBCOUNT=0
        while true; do
            if nc -w1 "${MONGO_HOST}" "${MONGO_PORT}" >/dev/null 2>&1; then
                break
            fi
            DBCOUNT=$((DBCOUNT+1))
            if [[ ${DBCOUNT} -gt 6 ]]; then
                echo "*** Defined MONGO_HOST ${MONGO_HOST} is not reachable, cannot proceed. ***"
                exit 1
            fi
            sleep 5
        done
        sed -i "s/~MONGO_USER~/${MONGO_USER}/" /defaults/system.properties
        sed -i "s/~MONGO_HOST~/${MONGO_HOST}/" /defaults/system.properties
        sed -i "s/~MONGO_PORT~/${MONGO_PORT}/" /defaults/system.properties
        sed -i "s/~MONGO_DBNAME~/${MONGO_DBNAME}/" /defaults/system.properties
        sed -i "s/~MONGO_PASS~/${MONGO_PASS}/" /defaults/system.properties
        if [[ "${MONGO_TLS,,}" = "true" ]]; then
            sed -i "s/~MONGO_TLS~/true/" /defaults/system.properties
        else
            sed -i "s/~MONGO_TLS~/false/" /defaults/system.properties
        fi
        if [[ -z "${MONGO_AUTHSOURCE}" ]]; then
            sed -i "s/~MONGO_AUTHSOURCE~//" /defaults/system.properties
        else
            sed -i "s/~MONGO_AUTHSOURCE~/\&authSource=${MONGO_AUTHSOURCE}/" /defaults/system.properties
        fi
        cp /defaults/system.properties /config/data
    fi
fi

echo "Generating RSA key..."
# Generate key if it doesn't exist
if [[ ! -f /config/data/keystore ]]; then
    keytool -genkey -keyalg RSA -alias unifi -keystore /config/data/keystore \
    -storepass aircontrolenterprise -keypass aircontrolenterprise -validity 3650 \
    -keysize 4096 -dname "cn=unifi" -ext san=dns:unifi
fi

# Launch the controller 
# Launch command found in /usr/lib/unifi/bin/unifi.init
echo "Launching UniFi..."
java \
    -Xms"${MEM_STARTUP}M" \
    -Xmx"${MEM_LIMIT}M" \
    -Dlog4j2.formatMsgNoLookups=true \
    -Dfile.encoding=UTF-8 \
    -Djava.awt.headless=true \
    -Dapple.awt.UIElement=true \
    -XX:+UseParallelGC \
    -XX:+ExitOnOutOfMemoryError \
    -XX:+CrashOnOutOfMemoryError \
    --add-opens java.base/java.lang=ALL-UNNAMED \
    --add-opens java.base/java.time=ALL-UNNAMED \
    --add-opens java.base/sun.security.util=ALL-UNNAMED \
    --add-opens java.base/java.io=ALL-UNNAMED \
    --add-opens java.rmi/sun.rmi.transport=ALL-UNNAMED \
    -jar /app/unifi/lib/ace.jar start;

echo "Exiting..."
