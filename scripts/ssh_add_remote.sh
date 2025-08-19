#!/bin/bash
# Exit the script if any command fails
set -e

read -p "Enter Username: " username
read -p "Enter Remote IP: " remoteip

# Path for private key
PRIVATE_KEY="$HOME/.ssh/id_ed25519"

# Check for private key existence
if [ ! -f "$PRIVATE_KEY" ]; then
    dialog --yesno "No SSH private key found at $PRIVATE_KEY. Generate a new one?" 7 60
    if [ $? -eq 0 ]; then
        ssh-keygen -t rsa -b 4096 -f "$PRIVATE_KEY"
    else
        clear
        echo "No key generated. Exiting."
        exit 1
    fi
fi

# Start ssh-agent and add key
eval "$(ssh-agent -s)"
ssh-add "$PRIVATE_KEY"

# Copy public key to remote
ssh-copy-id "$username@$remoteip"

echo "SSH key setup complete for $username@$remoteip."
