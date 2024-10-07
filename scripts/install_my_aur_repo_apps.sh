#!/bin/bash

# Ensure the script is run with sudo
if [ -z "$SUDO_USER" ]; then
    echo "This script must be run with sudo!"
    exit 1
fi

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Ensure sudo privileges are available
sudo -n true
test $? -eq 0 || { echo -e "${RED}You should have sudo privileges to run this script.${NC}"; exit 1; }

# Check if yay is installed, if not, install it
if ! command -v yay &> /dev/null; then
    echo -e "${YELLOW}'yay' is not installed. Installing yay...${NC}"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

# Prompt for package installation
echo -e "\n${CYAN}Do you want to install Dillacorn's chosen Arch AUR Linux applications? [y/n]${NC}"

# Read a single character without requiring the Enter key
read -n1 -s choice

# Check user input
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo -e "\n${GREEN}Proceeding with installation of Dillacorn's chosen Arch AUR Linux applications...${NC}"
    
    # Update the package list
    yay -Syu --noconfirm

    # Install the applications using yay (list format)
    yay -S --needed --noconfirm \
        qimgv \
        cava \
        otpclient \
        teams-for-linux \
        vibrantlinux \
        vesktop \
        spotify \
        obs-studio-git \
        handbrake-git \
        heroic-games-launcher-bin \
        protonup-qt \
        itch-setup-bin \
        moonlight-qt \
        sunshine \
        cura-bin \
        localsend-bin \
        librewolf-bin \
        ungoogled-chromium

    echo -e "\n${GREEN}Installation complete!${NC}"
else
    echo -e "\n${YELLOW}Skipping installation of Dillacorn's chosen Arch AUR Linux applications.${NC}"
    exit 0
fi
