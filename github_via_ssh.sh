#!/bin/bash

# This script connects to GitHub via SSH

# Function to prompt for user input
function prompt_user() {
    while true; do
        read -p "Enter your email: " email
        if [[ -n "$email" ]]; then
            break
        fi
        echo "Email cannot be empty. Please try again."
    done

    read -p "Enter the name of the key file (default: id_rsa): " key_file
    key_file=${key_file:-id_rsa}
}

# Check if xclip is installed
if ! command -v xclip &> /dev/null; then
    echo "xclip is not installed. Do you want to install it? (y/n)"
    read install_xclip
    if [[ $install_xclip == "y" ]]; then
        if [[ -x "$(command -v apt)" ]]; then
            sudo apt install xclip
        else
            echo "Package manager not supported. Please install xclip manually."
            exit 1
        fi
    else
        echo "xclip is useful to yank the public key after generation. 
        Please consider installing it. The script will continue without it."
    fi
fi

# Start of the script
echo "======================================="
echo "Welcome to the GitHub SSH setup script!"
echo "======================================="

# Prompt for user email and key file name
prompt_user

# Generate SSH key
if ssh-keygen -t rsa -b 4096 -C "$email" -f $HOME/.ssh/$key_file; then
    echo "SSH key generated successfully!"
else
    echo "Failed to generate SSH key. Please check your inputs and try again."
    exit 1
fi

# Initialize SSH agent and add the key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/$key_file

# Copy SSH key to clipboard if possible, otherwise print to console
if command -v xclip &> /dev/null; then
    xclip -sel clip < ~/.ssh/$key_file.pub
    echo "SSH key automatically copied to clipboard!"
else
    echo "SSH public key:"
    cat ~/.ssh/$key_file.pub
    echo "Please copy it manually."
fi

echo "Please add the SSH key to your GitHub account (https://github.com/settings/ssh/new) 
and try to connect to GitHub via SSH."

echo "======="
echo " Done!"
echo "======="

# End of the script
