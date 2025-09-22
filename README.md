# AWS EC2 VPC Lab

This repository documents the steps and configuration details for a hands-on AWS lab. The lab covers the following:

- Understanding and reviewing a Virtual Private Cloud (VPC) and its components
- Reviewing and understanding a VPC Security Group
- Launching an EC2 instance with a custom user data script to deploy a web application

## Table of Contents

- [Lab Overview](#lab-overview)
- [VPC Configuration](#vpc-configuration)
- [Security Group Configuration](#security-group-configuration)
- [EC2 Instance Launch](#ec2-instance-launch)
- [User Data Script](#user-data-script)
- [Lab Diagram](#lab-diagram)
- [Summary](#summary)

---

## Lab Overview

This lab walks through the configuration and deployment of an AWS environment suitable for running a web application. It utilizes core AWS resources: VPC, subnets, internet gateway, route table, security group, and EC2 instance.

---

## VPC Configuration

- **VPC Name:** Lab VPC
- **IPv4 CIDR Block:** `10.10.0.0/16`  
  - Provides 2^16 addresses: `10.10.0.0` to `10.10.255.255`
- **IPv6 CIDR Block:** None
- **DNS Resolution:** Enabled
- **DNS Hostnames:** Enabled

### Subnet

- **Name:** lab-2-public-subnet-1
- **IPv4 Range:** `10.10.1.0/24`
- **Availability Zone:** Single (does not span AZs)

### Internet Gateway

- Attached to VPC for external connectivity
- Supports IPv4 and IPv6

### Route Table

- Name: lab-2-rtb-public
- Enables:
  - Local subnet routing
  - Route to Internet Gateway
  - Route to S3 Gateway Endpoint

---

## Security Group Configuration

- **Name:** WebAppSG
- **Associated VPC:** Lab VPC
- **Inbound Rules:**
  - Allow TCP 80 from anywhere (HTTP)
  - Allow TCP 443 from anywhere (HTTPS)
- **Outbound Rules:**
  - Allow all to VPC Endpoint security group (AWS Services)
  - Allow UDP 53 to anywhere (DNS resolution)
  - Allow all to S3 prefix list (S3 access)

---

## EC2 Instance Launch

- **Name:** Web Application
- **AMI:** Amazon Linux 2023 (64-bit x86)
- **Instance Type:** t3.micro
- **Key Pair:** None (lab-only, no SSH access)
- **Network:**
  - VPC: Lab VPC
  - Subnet: lab-2-public-subnet-1
  - Auto-assign Public IP: Enabled
- **Security Group:** WebAppSG
- **IAM Instance Profile:** LabInstanceProfile
- **User Data Script:** See below

---

## User Data Script

This script is run on instance startup to install Node.js, retrieve app assets from S3, install dependencies, and launch the app.

```bash
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
```

Replace `S3_BUCKET_NAME` with your bucket name.

---

## Lab Diagram

```
[Internet]
    |
[Internet Gateway]
    |
[Lab VPC 10.10.0.0/16]
    |
[Public Subnet 10.10.1.0/24]
    |
[EC2 Instance: Web Application]
    |
[Security Group: WebAppSG]
    |
[S3 Endpoint for Asset Delivery]
```

---

## Summary

By following the steps above, you:

- Understood and reviewed VPC configuration
- Validated subnet, internet gateway, and route table
- Reviewed security group rules for your web app
- Launched and configured an EC2 instance with a user data script
- Successfully deployed a Node.js web application on AWS

---

## Files

- `README.md`: This documentation
- `userdata.sh`: The user data bootstrap script for the EC2 instance

---

## License

[MIT License](LICENSE)

---

## Author

beefychipmunky