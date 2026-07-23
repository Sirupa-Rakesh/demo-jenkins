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


DISK="/dev/nvme0n1"
PARTITION="${DISK}p4"
LV="/dev/RootVG/varVol"
MOUNT="/var"

echo "===== Current Disk Usage ====="
df -h "$MOUNT"

echo "===== Growing Partition ====="
sudo growpart $DISK 4

echo "===== Resizing Physical Volume ====="
sudo pvresize $PARTITION

echo "===== Extending Logical Volume ====="
sudo lvextend -l +100%FREE $LV

echo "===== Growing Filesystem ====="

FSTYPE=$(findmnt -n -o FSTYPE $MOUNT)

if [ "$FSTYPE" = "xfs" ]; then
    sudo xfs_growfs $MOUNT
elif [ "$FSTYPE" = "ext4" ]; then
    sudo resize2fs $LV
else
    echo "Unsupported filesystem: $FSTYPE"
    exit 1
fi

echo "===== Final Disk Usage ====="
df -h "$MOUNT"

echo "Resize completed successfully."

chmod +x "$0"