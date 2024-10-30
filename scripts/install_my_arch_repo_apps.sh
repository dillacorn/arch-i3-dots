#!/bin/bash

# Define color codes at the top
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Ensure the script is run with sudo/root privileges
if [ -z "$SUDO_USER" ]; then
    echo -e "${RED}This script must be run with sudo!${NC}"
    exit 1
fi

set -eu -o pipefail # Fail on error and report it, debug all lines

# Inform the user to enable the multilib repository
echo -e "${YELLOW}IMPORTANT: Ensure the multilib repository is enabled in /etc/pacman.conf before running this script.${NC}"
echo -e "${YELLOW}To enable it, uncomment the following lines in your /etc/pacman.conf file:${NC}"
echo -e "${CYAN}  [multilib]\n  Include = /etc/pacman.d/mirrorlist${NC}"
echo -e "${YELLOW}Then, run 'sudo pacman -Syu' to update the package list.${NC}"

# Function to install a package if not already installed
install_package() {
    local package="$1"
    if ! pacman -Qi "$package" &>/dev/null; then
        echo -e "${CYAN}Installing $package and its dependencies...${NC}"
        pacman -S --needed --noconfirm "$package"
    else
        echo -e "${YELLOW}$package is already installed. Skipping...${NC}"
    fi
}

# Forcefully remove jack2 and install pipewire-jack
if pacman -Qi jack2 &>/dev/null; then
    echo -e "${YELLOW}jack2 is installed, which conflicts with pipewire-jack.${NC}"
    echo -e "${CYAN}Forcefully removing jack2 and related dependencies...${NC}"
    pacman -Rdd --noconfirm jack2
fi
install_package "pipewire-jack"

# Prompt for package installation
echo -e "\n${CYAN}Do you want to install Dillacorn's chosen Arch Repo Linux applications? [y/n]${NC}"
read -n1 -s choice
echo

if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo -e "\n${GREEN}Proceeding with installation of Dillacorn's chosen Arch Repo Linux applications...${NC}"

    # Update the package list
    echo -e "${CYAN}Updating package list...${NC}"
    pacman -Syu --noconfirm

    # Install Window Management Tools
    echo -e "${CYAN}Installing window management tools...${NC}"
    for pkg in i3-wm i3status-rust i3lock feh nitrogen rofi dunst slop arandr xorg-server xorg-xinit \
               xf86-input-libinput xsettingsd xautolock xclip xsel playerctl xorg-xinput xdotool upower; do
        install_package "$pkg"
    done

    # Install Fonts
    echo -e "${CYAN}Installing fonts...${NC}"
    for pkg in ttf-font-awesome ttf-hack ttf-dejavu ttf-liberation noto-fonts; do
        install_package "$pkg"
    done

    # Install Themes
    echo -e "${CYAN}Installing themes...${NC}"
    for pkg in papirus-icon-theme materia-gtk-theme xcursor-comix; do
        install_package "$pkg"
    done

    # Install Terminal Applications
    echo -e "${CYAN}Installing terminal applications...${NC}"
    for pkg in micro alacritty fastfetch btop htop curl wget git dos2unix brightnessctl ipcalc cmatrix sl asciiquarium figlet; do
        install_package "$pkg"
    done

    # Install Utilities
    echo -e "${CYAN}Installing general utilities...${NC}"
    for pkg in steam thermald lxsession lxappearance networkmanager network-manager-applet bluez bluez-utils \
               solaar blueman pavucontrol pcmanfm gvfs gvfs-smb gvfs-mtp gvfs-afc xdg-desktop-portal \
               xdg-desktop-portal-gtk qbittorrent filelight timeshift flameshot maim imagemagick pipewire pipewire-pulse pipewire-alsa; do
        install_package "$pkg"
    done

    # Install Multimedia Tools
    echo -e "${CYAN}Installing multimedia tools...${NC}"
    for pkg in ffmpeg avahi mpv peek cheese exiv2 audacity krita shotcut filezilla; do
        install_package "$pkg"
    done

    # Start and enable Avahi daemon
    echo -e "${CYAN}Starting and enabling avahi-daemon...${NC}"
    systemctl enable --now avahi-daemon

    # Install Development Tools
    echo -e "${CYAN}Installing development tools...${NC}"
    for pkg in base-devel archlinux-keyring clang ninja go rust octave okular tigervnc bleachbit virt-manager \
               qemu virt-viewer vde2 libguestfs dmidecode gamemode nftables; do
        install_package "$pkg"
    done

    # Network and Security Configuration
    echo -e "${CYAN}Installing networking and security tools...${NC}"
    systemctl disable --now unbound systemd-resolved || true
    systemctl mask systemd-resolved || true

    install_package "ufw"
    systemctl enable --now ufw
    ufw allow in on virbr0
    ufw allow out on virbr0
    ufw allow out to any port 53
    ufw allow out to any port 80
    ufw allow out to any port 443
    ufw default allow routed
    ufw reload

    for pkg in wireguard-tools wireplumber openssh iptables systemd-resolvconf bridge-utils qemu-guest-agent dnsmasq dhcpcd inetutils openbsd-netcat; do
        install_package "$pkg"
    done

    echo -e "${CYAN}Enabling and starting libvirtd and dnsmasq...${NC}"
    systemctl enable --now libvirtd dnsmasq

    echo -e "${CYAN}Enabling and starting thermald...${NC}"
    systemctl enable --now thermald

    # Enable and start Bluetooth service
    if pacman -Qi bluez &>/dev/null && pacman -Qi bluez-utils &>/dev/null; then
        systemctl enable --now bluetooth.service
        echo -e "${GREEN}Bluetooth service started successfully.${NC}"
    else
        echo -e "${RED}Bluetooth service could not be enabled. bluez or bluez-utils is missing.${NC}"
    fi
fi

    # Print success message after installation
    echo -e "\n${GREEN}Successfully installed all of Dillacorn's Arch Linux chosen applications!${NC}"
else
    echo -e "\n${YELLOW}Skipping installation of Dillacorn's chosen Arch Linux applications.${NC}"
    exit 0
