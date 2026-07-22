#!/bin/bash
set -e
# Install dnf plugins
dnf install -y dnf-plugins-core

# Add Docker Repository
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Install Docker
dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker
systemctl enable --now docker

# Create Network
docker network create sonarqube || true

# PostgreSQL
docker run -d \
--name postgres \
--restart unless-stopped \
--network sonarqube \
-e POSTGRES_USER=sonar \
-e POSTGRES_PASSWORD=sonar \
-e POSTGRES_DB=sonarqube \
postgres:15


sudo growpart /dev/nvme0n1 4
sudo pvresize /dev/nvme0n1p4
sudo vgs


sudo lvextend -L +30G /dev/mapper/RootVG-varVol
sudo xfs_growfs /var
df -h /var


sudo docker system prune -af
sudo docker run -d --name sonarqube --restart always -p 9000:9000 sonarqube:lts-community


# SonarQube
docker run -d \
--name sonarqube \
--restart unless-stopped \
--network sonarqube \
-p 9000:9000 \
-e SONAR_JDBC_URL=jdbc:postgresql://postgres:5432/sonarqube \
-e SONAR_JDBC_USERNAME=sonar \
-e SONAR_JDBC_PASSWORD=sonar \
sonarqube:25.8.0.112029-community
 my sir is using ubuntu once checsk