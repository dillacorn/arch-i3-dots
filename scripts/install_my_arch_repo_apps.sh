#!/bin/bash

# Ensure the script is run with sudo/root privileges
if [ -z "$SUDO_USER" ]; then
    echo -e "${RED}This script must be run with sudo!${NC}"
    exit 1
fi

set -eu -o pipefail # Fail on error and report it, debug all lines

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Inform the user to enable the multilib repository
echo -e "${YELLOW}IMPORTANT: Ensure the multilib repository is enabled in /etc/pacman.conf before running this script.${NC}"
echo -e "${YELLOW}To enable it, uncomment the following lines in your /etc/pacman.conf file:${NC}"
echo -e "${CYAN}  [multilib]\n  Include = /etc/pacman.d/mirrorlist${NC}"
echo -e "${YELLOW}Then, run 'sudo pacman -Syu' to update the package list.${NC}"

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

# Forcefully remove jack2 and its dependencies, then install pipewire-jack
if pacman -Qi jack2 &>/dev/null; then
    echo -e "${YELLOW}jack2 is installed, which conflicts with pipewire-jack.${NC}"
    echo -e "${CYAN}Forcefully removing jack2 and related dependencies...${NC}"
    pacman -Rdd --noconfirm jack2

    echo -e "${CYAN}Installing pipewire-jack...${NC}"
    install_package "pipewire-jack"
else
    echo -e "${GREEN}jack2 is not installed. Proceeding with pipewire-jack installation.${NC}"
    install_package "pipewire-jack"
fi

# Prompt for package installation
echo -e "\n${CYAN}Do you want to install Dillacorn's chosen Arch Repo Linux applications? [y/n]${NC}"

# Read a single character without requiring the Enter key
read -n1 -s choice
echo # Move to a new line after the choice

# Check user input
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo -e "\n${GREEN}Proceeding with installation of Dillacorn's chosen Arch Repo Linux applications...${NC}"
    
    # Update the package list
    echo -e "${CYAN}Updating package list...${NC}"
    pacman -Syu --noconfirm

    # ----------------------------
    # Window Management Tools
    # ----------------------------
    echo -e "${CYAN}Installing window management tools...${NC}"
    for pkg in i3-wm i3status-rust i3lock feh nitrogen rofi slop arandr xorg-server xorg-xinit xf86-input-libinput xsettingsd xautolock xclip xsel playerctl xorg-xinput xdotool upower; do
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
    for pkg in micro alacritty fastfetch btop htop curl wget git dos2unix brightnessctl ipcalc cmatrix sl asciiquarium figlet; do
        install_package "$pkg"
    done

    # ----------------------------
    # Utilities
    # ----------------------------
    echo -e "${CYAN}Installing general utilities...${NC}"
    for pkg in steam dunst lxsession lxappearance networkmanager network-manager-applet bluez bluez-utils solaar blueman pavucontrol pcmanfm gvfs gvfs-smb gvfs-mtp gvfs-afc xdg-desktop-portal qbittorrent filelight timeshift flameshot maim imagemagick; do
        install_package "$pkg"
    done

    # ----------------------------
    # Multimedia Tools
    # ----------------------------
    echo -e "${CYAN}Installing multimedia tools...${NC}"
    for pkg in ffmpeg avahi mpv peek cheese exiv2 audacity krita shotcut spotify-launcher filezilla; do
        install_package "$pkg"
    done

    # Start and enable Avahi daemon
    echo -e "${CYAN}Starting and enabling avahi-daemon...${NC}"
    systemctl enable avahi-daemon
    systemctl start avahi-daemon

    # ----------------------------
    # Development Tools
    # ----------------------------
    echo -e "${CYAN}Installing development tools...${NC}"
    for pkg in base-devel archlinux-keyring clang ninja go rust octave okular tigervnc bleachbit virt-manager qemu virt-viewer vde2 libguestfs dmidecode gamemode nftables; do
        install_package "$pkg"
    done

# ----------------------------
# Networking and Security
# ----------------------------
echo -e "${CYAN}Installing networking and security tools...${NC}"

# Stop conflicting services if they are running
echo -e "${CYAN}Disabling and stopping unbound and systemd-resolved to prevent conflicts...${NC}"
systemctl stop unbound systemd-resolved || true
systemctl disable unbound systemd-resolved || true
systemctl mask systemd-resolved || true
rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" | tee /etc/resolv.conf

# Install UFW if not already installed and allow virbr0 traffic
if ! pacman -Qs ufw > /dev/null; then
    echo -e "${CYAN}Installing ufw...${NC}"
    install_package "ufw"
    ufw enable
    systemctl enable ufw
fi
echo -e "${CYAN}Allowing all traffic through virbr0 interface...${NC}"
ufw allow in on virbr0
ufw allow out on virbr0

# Install required networking and security tools
for pkg in wireguard-tools wireplumber openssh iptables systemd-resolvconf bridge-utils qemu-guest-agent dnsmasq dhcpcd inetutils openbsd-netcat pipewire pipewire-pulse pipewire-alsa bluez; do
    install_package "$pkg"
done

# Ensure libvirtd is enabled
echo -e "${CYAN}Ensuring libvirtd is enabled...${NC}"
systemctl enable libvirtd

# Stop and clean up libvirt and virtlogd sockets to avoid stale files
echo -e "${CYAN}Stopping libvirt and virtlogd services and removing stale sockets...${NC}"
systemctl stop libvirtd virtlogd || true
systemctl stop libvirtd-admin.socket libvirtd-ro.socket libvirtd.socket virtlogd-admin.socket virtlogd.socket || true
rm -rf /run/libvirt /run/virtlogd || true

# Ensure correct permissions for /run/libvirt and /run/virtlogd
echo -e "${CYAN}Recreating directories with correct permissions...${NC}"
mkdir -p /run/libvirt /run/virtlogd
chown libvirt-qemu:kvm /run/libvirt /run/virtlogd
chmod 755 /run/libvirt /run/virtlogd

# Start libvirt and let it set up virbr0 automatically
echo -e "${CYAN}Starting libvirt services to set up virbr0...${NC}"
systemctl start libvirtd virtlogd
sleep 3

# Restart dnsmasq to clear any old settings
echo -e "${CYAN}Restarting dnsmasq...${NC}"
systemctl restart dnsmasq
systemctl enable dnsmasq

# Verify that libvirt and dnsmasq are running
echo -e "${CYAN}Verifying libvirt and dnsmasq services...${NC}"
if systemctl is-active --quiet libvirtd && systemctl is-active --quiet dnsmasq; then
    echo -e "${GREEN}libvirt and dnsmasq are active.${NC}"
else
    echo -e "${RED}Error: libvirt or dnsmasq service is not active. Check services.${NC}"
    exit 1
fi

# Final success message
echo -e "\n${GREEN}Network and security configuration completed successfully!${NC}"

    # ----------------------------
    # Bluetooth Services
    # ----------------------------
    echo -e "${CYAN}Enabling and starting Bluetooth service...${NC}"

    # Check if bluez and bluez-utils are installed, then enable and start the Bluetooth service
    if pacman -Qi bluez &>/dev/null && pacman -Qi bluez-utils &>/dev/null; then
        systemctl enable bluetooth.service
        systemctl start bluetooth.service
        
        # Verify if the Bluetooth service started successfully
        if systemctl is-active --quiet bluetooth.service; then
            echo -e "${GREEN}Bluetooth service started successfully.${NC}"
        else
            echo -e "${RED}Bluetooth service failed to start. Please check the service status.${NC}"
        fi
    else
        echo -e "${RED}Bluetooth service could not be enabled because bluez or bluez-utils is not installed.${NC}"
    fi

    # Print success message after installation
    echo -e "\n${GREEN}Successfully installed all of Dillacorn's Arch Linux chosen applications!${NC}"
else
    echo -e "\n${YELLOW}Skipping installation of Dillacorn's chosen Arch Linux applications.${NC}"
    exit 0
fi
