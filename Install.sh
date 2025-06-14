#!/bin/bash

# HackOne Installation Script
# Author: Hacker Devil
# Usage: bash install.sh

clear
echo -e "\e[1;32m
  _    _            _    ____              _      
 | |  | |          | |  |  _ \            | |     
 | |__| | __ _  ___| | _| |_) | ___   ___ | | ___ 
 |  __  |/ _\` |/ __| |/ /  _ < / _ \ / _ \| |/ _ \\
 | |  | | (_| | (__|   <| |_) | (_) | (_) | |  __/
 |_|  |_|\__,_|\___|_|\_\____/ \___/ \___/|_|\___|
                                                  
\033[0m"
echo -e "\n\e[1;34m[+] Starting HackOne Installer...\e[0m"

# Check for root
if [[ $EUID -ne 0 ]]; then
  echo -e "\n\e[1;31m[-] Please run this script as root!\e[0m"
  exit 1
fi

# Update & install essential packages
echo -e "\n[+] Updating packages..."
apt update -y && apt upgrade -y

echo -e "\n[+] Installing required packages..."
pkg install -y git curl wget python php nmap openssh tsu hydra toilet figlet ruby nodejs
pip install --upgrade pip
pip install requests lolcat

# Fix permissions and line endings
echo -e "\n[+] Fixing script permissions and format..."
find . -type f -name "*.sh" -exec chmod +x {} \;
find . -type f -name "*.sh" -exec dos2unix {} \; 2>/dev/null

# Shortcut setup (optional)
echo -e "\n[+] Setting up launch shortcut..."
ln -sf "$(pwd)/HackerOne.sh" /data/data/com.termux/files/usr/bin/hackone
chmod +x /data/data/com.termux/files/usr/bin/hackone

# Final Message
echo -e "\n\e[1;32m[✓] HackOne is ready!\e[0m"
echo -e "\n🚀 Run the tool using: \e[1;36mhackone\e[0m\n"
