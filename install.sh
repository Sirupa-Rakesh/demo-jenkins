#!/bin/bash
set -e  # Exit on error


git clone https://github.com/Sirupa-Rakesh/jenkins-install.git


echo "Installing Jenkins..."
sudo curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
sudo yum install fontconfig java-21-openjdk -y
sudo yum install jenkins -y
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Jenkins installation complete!"

#chmod +x jenkins-install.sh, bash jenkins-install.sh,      