#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Update packages
apt-get update -y

# Install required packages
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    cloud-guest-utils

# Add Docker GPG key
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
apt-get update -y

# Install Docker
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Enable Docker
systemctl enable docker
systemctl start docker

# Create Docker network
docker network create sonarqube || true

# PostgreSQL Container
docker run -d \
  --name postgres \
  --restart unless-stopped \
  --network sonarqube \
  -e POSTGRES_USER=sonar \
  -e POSTGRES_PASSWORD=sonar \
  -e POSTGRES_DB=sonarqube \
  postgres:15

# Increase /var filesystem (only if your AMI uses LVM)
growpart /dev/nvme0n1 4 || true
pvresize /dev/nvme0n1p4 || true
lvextend -L +30G /dev/mapper/RootVG-varVol || true
xfs_growfs /var || true

# Clean Docker
docker system prune -af

# SonarQube Container
docker run -d \
  --name sonarqube \
  --restart unless-stopped \
  --network sonarqube \
  -p 9000:9000 \
  -e SONAR_JDBC_URL=jdbc:postgresql://postgres:5432/sonarqube \
  -e SONAR_JDBC_USERNAME=sonar \
  -e SONAR_JDBC_PASSWORD=sonar \
  sonarqube:25.8.0.112029-community