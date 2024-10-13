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

# Function to install a package and its dependencies if not already installed
install_package() {
    local package="$1"
    if ! pacman -Qi "$package" &>/dev/null; then
        echo -e "${CYAN}Installing $package and its dependencies...${NC}"
        sudo pacman -S --needed --noconfirm "$package"
    else
        echo -e "${YELLOW}$package is already installed. Skipping...${NC}"
    fi
}

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
    for pkg in i3-wm i3status-rust i3lock feh nitrogen rofi slop arandr xorg-server xorg-xinit xf86-input-libinput xsettingsd xautolock xclip xsel playerctl xorg-xinput; do
        install_package "$pkg"
    done

    # ----------------------------
    # Fonts
    # ----------------------------
    echo -e "${CYAN}Installing fonts...${NC}"
    for pkg in ttf-font-awesome ttf-hack ttf-dejavu ttf-liberation noto-fonts; do
        install_package "$pkg"
    done

    # ----------------------------
    # Themes
    # ----------------------------
    echo -e "${CYAN}Installing themes...${NC}"
    for pkg in papirus-icon-theme materia-gtk-theme xcursor-comix; do
        install_package "$pkg"
    done

    # ----------------------------
    # Terminal Applications
    # ----------------------------
    echo -e "${CYAN}Installing terminal applications...${NC}"
    for pkg in micro alacritty fastfetch btop htop curl wget git dos2unix brightnessctl; do
        install_package "$pkg"
    done

    # ----------------------------
    # Utilities
    # ----------------------------
    echo -e "${CYAN}Installing general utilities...${NC}"
    for pkg in dunst lxsession lxappearance networkmanager network-manager-applet solaar blueman pavucontrol pcmanfm gvfs gvfs-smb gvfs-mtp gvfs-afc filelight timeshift flameshot; do
        install_package "$pkg"
    done

    # ----------------------------
    # Multimedia Tools
    # ----------------------------
    echo -e "${CYAN}Installing multimedia tools...${NC}"
    for pkg in ffmpeg mpv peek cheese exiv2 audacity obs-studio krita shotcut telegram-desktop ncspot filezilla; do
        install_package "$pkg"
    done

    # ----------------------------
    # Development Tools
    # ----------------------------
    echo -e "${CYAN}Installing development tools...${NC}"
    for pkg in base-devel clang ninja go rust octave okular tigervnc bleachbit virt-manager gamemode; do
        install_package "$pkg"
    done

    # ----------------------------
    # Networking and Security
    # ----------------------------
    echo -e "${CYAN}Installing networking and security tools...${NC}"
    if ! pacman -Qs ufw > /dev/null; then
        echo -e "${CYAN}Installing ufw...${NC}"
        install_package "ufw"
        echo -e "${CYAN}Enabling ufw...${NC}"
        sudo ufw enable
    else
        echo -e "${YELLOW}ufw is already installed, skipping installation and enabling.${NC}"
    fi

    # Install other networking and security tools
    for pkg in wireguard-tools wireplumber openssh systemd-resolvconf bridge-utils qemu-guest-agent inetutils pipewire-pulse bluez; do
        install_package "$pkg"
    done

    # Check if Moonlight is installed, then configure firewall
    if pacman -Qs moonlight-qt > /dev/null; then
        echo -e "${CYAN}Moonlight detected! Configuring firewall rules for Moonlight...${NC}"
        sudo ufw allow 48010/tcp
        sudo ufw allow 48000/udp
        sudo ufw allow 48010/udp
        echo -e "${GREEN}Firewall rules for Moonlight configured successfully.${NC}"
    else
        echo -e "${YELLOW}Moonlight is not installed. Skipping firewall configuration for Moonlight.${NC}"
    fi

    # Print success message after installation
    echo -e "\n${GREEN}Successfully installed all of Dillacorn's Arch Linux chosen applications!${NC}"
else
    echo -e "\n${YELLOW}Skipping installation of Dillacorn's chosen Arch Linux applications.${NC}"
    exit 0
fi
