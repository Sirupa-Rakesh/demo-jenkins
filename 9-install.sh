#!/bin/bash
set -e  # Exit on error
REPO_URL="https://github.com/Sirupa-Rakesh/demo-jenkins.git"
DEST_DIR="/home/ec2-user/demo-jenkins"
# Make this script executable (optional)

chmod +x "$0"

# Clone the repository if it doesn't already exist
if [ ! -d "$DEST_DIR" ]; then
    git clone "$REPO_URL" "$DEST_DIR"
    echo "Repository cloned successfully...."
else
    echo "Repository already exists."
fi

echo "Installing Jenkins..."
sudo curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
sudo yum install fontconfig java-21-openjdk -y
sudo yum install jenkins -y
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Jenkins installation complete!

#chmod +x jenkins-install.sh, bash jenkins-install.sh,      