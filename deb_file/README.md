Pre-req:
- Update new_image.sh to login to your container repository and update the tagging and push commands to use it
- Update Dockerfile as needed (maintainer, etc). The script will update the version label for you. If you prefer to use the stable version, you can modify the Dockerfile and you won't need to worry about the .deb file staging.

Download the .deb file of the Unifi controller you with to package and place it in this directory (deb_file/.).

Then run ./new_image.sh from the repo root which will create the image and push to your container registry.
