Download the .deb file of the Unifi controller you with to package and place it in this directory.

Then run ./generate_tar.sh to generate the .tgz file and update the Dockerfile to use it.

Then you can build using the Dockerfile, which will build using the contents from the .deb.