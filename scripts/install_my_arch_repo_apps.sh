#!/bin/bash

# Ensure the script is run with sudo
if [ -z "$SUDO_USER" ]; then
    echo "This script must be run with sudo!"
    exit 1
fi

set -eu -o pipefail # fail on error and report it, debug all lines

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if the user has sudo privileges
if ! sudo -n true 2>/dev/null; then
    echo -e "${RED}You should have sudo privileges to run this script.${NC}"
    exit 1
fi

# Prompt for package installation
echo -e "\n${CYAN}Do you want to install Dillacorn's chosen Arch Repo Linux applications? [y/n]${NC}"

# Read a single character without requiring the Enter key
read -n1 -s choice

# Check user input
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo -e "\n${GREEN}Proceeding with installation of Dillacorn's chosen Arch Repo Linux applications...${NC}"
    
    # Update the package list
    echo -e "${CYAN}Updating package list...${NC}"
    sudo pacman -Syu --noconfirm

    # Install the applications using pacman (list format)
    sudo pacman -S --needed --noconfirm \
        i3-wm \
        ttf-font-awesome \
        ttf-hack \
        i3status \
        i3lock \
        sed \
        feh \
        rofi \
        rofimoji \
        grim \
        slop \
        dunst \
        lxsession \
        lxappearance \
        micro \
        fastfetch \
        brightnessctl \
        dos2unix \
        networkmanager \
        network-manager-applet \
        solaar \
        blueman \
        arandr \
        pavucontrol \
        pcmanfm \
        ffmpeg \
        mpv \
        cheese \
        exiv2 \
        flameshot \
        htop \
        btop \
        curl \
        wget \
        git \
        octave \
        okular \
        tigervnc \
        timeshift \
        virt-manager \
        wireguard-tools \
        wireplumber \
        gamemode \
        alacritty \
        gcolor3 \
        audacity \
        krita \
        shotcut \
        bleachbit \
        ncspot \
        telegram-desktop \
        filezilla \
        papirus-icon-theme \
        materia-gtk-theme \
        xcursor-comix \
        xorg-server \
        xorg-xinit \
        xf86-input-libinput \
        xautolock \
        xclip \
        xsel \
        pipewire-pulse \
        bluez \
        systemd-resolvconf \
        bridge-utils \
        qemu-guest-agent \
        lib32-mesa \
        lib32-nvidia-utils \
        steam \
        base-devel \
        clang \
        ninja \
        go \
        rust \
        gn

    # Print success message after installation
    echo -e "\n${GREEN}Successfully installed all of Dillacorn's Arch Linux chosen applications!${NC}"
else
    echo -e "\n${YELLOW}Skipping installation of Dillacorn's chosen Arch Linux applications.${NC}"
    exit 0
fi
