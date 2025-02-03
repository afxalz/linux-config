#!/bin/bash

echo "Installing docker"

if dialog --title "Cleanup" \
       --yesno "It is recommended to uninstall the previous docker installation and clean the images, containers, and volumes to prevent any colflicts. Do you want to proceed?" 10 80; then
    
    echo -e "Purging old installation"
    sudo apt-get purge -y docker-ce \
            docker-ce-cli \
            containerd.io \
            docker-buildx-plugin \
            docker-compose-plugin \
            docker-ce-rootless-extras
    
    echo "Removing existing images, containers and volumes"
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd

    echo "Removing apt source.list and old keyring"
    sudo rm /etc/apt/sources.list.d/docker.list
    sudo rm /etc/apt/keyrings/docker.asc
else
    echo "Selected 'No'. Will proceed without cleaning!"
fi

echo "Adding docker official GPG key"
# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

echo "Installing docker through apt"
sudo apt-get install -y docker-ce \
 docker-ce-cli \
 containerd.io \
 docker-buildx-plugin \
 docker-compose-plugin

if dialog --title "User group" \
       --yesno "To avoid needing 'sudo' before each docker command, add $USER to the 'docker' user group. Do you want to proceed?" 10 80; then
    echo -e "Adding $USER to the docker user group"
    sudo groupadd docker
    sudo usermod -aG docker
    newgrp docker
else
    echo "Selected 'No'. Will proceed"
fi
exit 0