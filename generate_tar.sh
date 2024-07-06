#!/bin/bash

# Download the .deb file from the Unifi UI and place it in the deb_file subpath.
#    Then run this script to generate the .tgz file to be used in the Dockerfile.

# Check the number of arguments
if [ -z "$1" ]; then
    echo "Please provide the UniFi version as an argument (e.g., 8.2.93, 8.3.20, etc)."
    exit 1
fi

# Check if the UniFi version is in the correct format
version_regex="^[0-9]+\.[0-9]+\.[0-9]+$"
if [[ ! $1 =~ $version_regex ]]; then
    echo "Invalid UniFi version format. Please use the format X.Y.Z (e.g., 8.2.93, 8.3.20, etc)."
    exit 1
fi
unifi_version=$1

# Package the .tgz file
pushd deb_file
dpkg-deb -x *.deb .
tar -czvf "../unifi-${unifi_version}.tgz" -C ./usr/lib/unifi .
popd
rm -rf deb_file/etc deb_file/usr deb_file/lib

# Update Dockerfile
sed -i "s/LABEL version=\".*\"/LABEL version=\"$unifi_version\"/" Dockerfile
sed -i "s/unifi-.*\.tgz/unifi-${unifi_version}.tgz/" Dockerfile

echo "Finished."