#!/bin/bash -xe

# Installs Node.js
dnf install nodejs20 nodejs20-npm -y

# Downloads an NPM cache from S3 to aid package installation
aws s3 cp s3://S3_BUCKET_NAME/npm-cache.tar.gz /var/cache/npm-cache.tar.gz

# Extracts the cache to a directory
mkdir -p /root/.npm
tar xzf /var/cache/npm-cache.tar.gz -C /root/.npm/

# Downloads the web app code as a zip file
mkdir -p /var/app/
aws s3 cp s3://S3_BUCKET_NAME/app.zip /var/app/app.zip

# Extracts the web app zip to a directory
unzip /var/app/app.zip -d /var/app/

# Runs an offline npm install for needed packages
cd /var/app
npm install --offline

# Starts the Node.js web app
npm start