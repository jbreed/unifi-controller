#!/bin/bash

# This script packages a UniFi .deb into a .tgz file and builds/pushes a container image.
# The script automatically detects the version (X.Y.Z) from the .deb filename.

# 1) Locate the .deb file in deb_file/
deb_path=$(ls deb_file/*.deb 2>/dev/null)
if [[ -z "$deb_path" ]]; then
    echo "No .deb file found in 'deb_file/' directory. Aborting."
    exit 1
fi

# 2) Extract the version (e.g. "9.0.106") from the filename
#    We assume the .deb filename contains something like: "b0fe-debian-9.0.106-..."
filename=$(basename "$deb_path")
unifi_version=$(echo "$filename" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if [[ -z "$unifi_version" ]]; then
    echo "Could not detect a version (X.Y.Z) pattern in: $filename"
    exit 1
fi

echo "Detected UniFi version: $unifi_version"

# 3) Package the .tgz file
pushd deb_file >/dev/null
dpkg-deb -x *.deb .
tar -czvf "../unifi-${unifi_version}.tgz" -C ./usr/lib/unifi .
popd >/dev/null

# 4) Clean up extracted dirs
rm -rf deb_file/etc deb_file/usr deb_file/lib

# 5) Update Dockerfile
sed -i "s/LABEL version=\".*\"/LABEL version=\"$unifi_version\"/" Dockerfile
sed -i "s/unifi-.*\.tgz/unifi-${unifi_version}.tgz/" Dockerfile

# 6) Build the Docker image
podman build -t "docker.io/jbreed/unifi-controller:${unifi_version}" .
podman tag "docker.io/jbreed/unifi-controller:${unifi_version}" "docker.io/jbreed/unifi-controller:latest"

# 7) Authenticate and push
podman login -u jbreed
podman push "docker.io/jbreed/unifi-controller:${unifi_version}"
podman push "docker.io/jbreed/unifi-controller:latest"

echo "Finished building and pushing unifi-controller:${unifi_version} (and latest)."

