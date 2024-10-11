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

    # ----------------------------
    # Window Management Tools
    # ----------------------------
    echo -e "${CYAN}Installing window management tools...${NC}"
    sudo pacman -S --needed --noconfirm \
        i3-wm \
        i3status \
        i3lock \
        feh \
        rofi \
        slop \
        arandr \
        xorg-server \
        xorg-xinit \
        xf86-input-libinput \
        xautolock \
        xclip \
        xsel \
        playerctl \
        xorg-xinput

    # ----------------------------
    # Fonts
    # ----------------------------
    echo -e "${CYAN}Installing fonts...${NC}"
    sudo pacman -S --needed --noconfirm \
        ttf-font-awesome \
        ttf-hack \
        ttf-dejavu \
        ttf-liberation \
        noto-fonts

    # ----------------------------
    # Utilities
    # ----------------------------
    echo -e "${CYAN}Installing general utilities...${NC}"
    sudo pacman -S --needed --noconfirm \
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
        pavucontrol \
        pcmanfm \
        gvfs \
        gvfs-smb \
        gvfs-mtp \
        gvfs-afc \
        filelight \
        timeshift \
        btop \
        htop \
        flameshot \
        curl \
        wget \
        git \
        alacritty \
        gcolor3 \
        papirus-icon-theme \
        materia-gtk-theme \
        xcursor-comix

    # ----------------------------
    # Multimedia Tools
    # ----------------------------
    echo -e "${CYAN}Installing multimedia tools...${NC}"
    sudo pacman -S --needed --noconfirm \
        ffmpeg \
        mpv \
        cheese \
        exiv2 \
        audacity \
        obs-studio \
        krita \
        shotcut \
        telegram-desktop \
        ncspot \
        filezilla

    # ----------------------------
    # Development Tools
    # ----------------------------
    echo -e "${CYAN}Installing development tools...${NC}"
    sudo pacman -S --needed --noconfirm \
        base-devel \
        clang \
        ninja \
        go \
        rust \
        octave \
        okular \
        tigervnc \
        steam \
        lib32-mesa \
        bleachbit \
        virt-manager \
        gamemode

    # ----------------------------
    # Networking and Security
    # ----------------------------
    echo -e "${CYAN}Installing networking and security tools...${NC}"
    sudo pacman -S --needed --noconfirm \
        wireguard-tools \
        wireplumber \
        openssh \
        ufw \
        systemd-resolvconf \
        bridge-utils \
        qemu-guest-agent \
        inetutils \
        pipewire-pulse \
        bluez

    # Firewall configuration for Moonlight
    echo -e "${CYAN}Configuring firewall rules for Moonlight...${NC}"
    sudo ufw allow 48010/tcp
    sudo ufw allow 48000/udp
    sudo ufw allow 48010/udp
    echo -e "${GREEN}Firewall rules for Moonlight configured successfully.${NC}"

    # Print success message after installation
    echo -e "\n${GREEN}Successfully installed all of Dillacorn's Arch Linux chosen applications!${NC}"
else
    echo -e "\n${YELLOW}Skipping installation of Dillacorn's chosen Arch Linux applications.${NC}"
    exit 0
fi
