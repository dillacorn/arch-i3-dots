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

# Function to install a package and its dependencies if not already installed
install_package() {
    local package="$1"
    if ! pacman -Qi "$package" &>/dev/null; then
        echo -e "${CYAN}Installing $package and its dependencies...${NC}"
        pacman -S --needed --noconfirm "$package"
    else
        echo -e "${YELLOW}$package is already installed. Skipping...${NC}"
    fi
}

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
    for pkg in i3-wm i3status-rust i3lock feh nitrogen rofi slop arandr xorg-server xorg-xinit xf86-input-libinput xsettingsd xautolock xclip xsel playerctl xorg-xinput xdotool; do
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
    for pkg in dunst lxsession lxappearance networkmanager network-manager-applet solaar blueman pavucontrol pcmanfm gvfs gvfs-smb gvfs-mtp gvfs-afc qbittorrent filelight timeshift flameshot maim imagemagick; do
        install_package "$pkg"
    done

    # ----------------------------
    # Multimedia Tools
    # ----------------------------
    echo -e "${CYAN}Installing multimedia tools...${NC}"
    for pkg in ffmpeg avahi mpv peek cheese exiv2 audacity krita shotcut ncspot filezilla; do
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
    for pkg in base-devel clang ninja go rust octave okular tigervnc bleachbit virt-manager qemu dmidecode gamemode nftables; do
        install_package "$pkg"
    done

    # ----------------------------
    # Networking and Security
    # ----------------------------
    echo -e "${CYAN}Installing networking and security tools...${NC}"

    # Install UFW if not already installed and enable it
    if ! pacman -Qs ufw > /dev/null; then
        echo -e "${CYAN}Installing ufw...${NC}"
        install_package "ufw"

        # Enable UFW and set it to start on boot
        echo -e "${CYAN}Enabling UFW and configuring it to start on boot...${NC}"
        ufw enable
        systemctl enable ufw
    else
        echo -e "${YELLOW}UFW is already installed, skipping installation.${NC}"
    fi

    # Allow necessary ports for VM (you can modify or add ports as per your need)
    echo -e "${CYAN}Configuring UFW to allow VM traffic...${NC}"
    for port in 22 80 443; do
        ufw allow in on virbr0 to any port "$port"
    done

    # Install other networking and security tools
    for pkg in wireguard-tools wireplumber openssh systemd-resolvconf bridge-utils qemu-guest-agent dnsmasq dhcpcd inetutils pipewire-pulse bluez; do
        install_package "$pkg"
    done
    
    # Check if Moonlight is installed, then configure firewall
    if pacman -Qs moonlight-qt > /dev/null; then
        echo -e "${CYAN}Moonlight detected! Configuring firewall rules for Moonlight...${NC}"
        ufw allow 48010/tcp
        ufw allow 48000/udp
        ufw allow 48010/udp
        echo -e "${GREEN}Firewall rules for Moonlight configured successfully.${NC}"
    else
        echo -e "${YELLOW}Moonlight is not installed. Skipping firewall configuration for Moonlight.${NC}"
    fi

    # Enable libvirtd if it's installed and configure networking if not running in a VM
echo -e "${CYAN}Configuring libvirt and networking...${NC}"
if pacman -Qs libvirt > /dev/null; then
    echo -e "${CYAN}libvirt is installed. Enabling and starting libvirtd...${NC}"
    systemctl enable --now libvirtd

    # Verify if libvirtd started successfully
    if ! systemctl is-active --quiet libvirtd; then
        echo -e "${RED}libvirtd service failed to start. Please check the service status.${NC}"
        exit 1
    fi

    # Check if the script is running in a virtualized environment
    if systemd-detect-virt -q; then
        echo -e "${YELLOW}Running in a virtualized environment. Skipping network configuration.${NC}"
    else
        # Destroy and undefine the existing default network if it exists
        echo -e "${CYAN}Destroying and undefining existing default network if exists...${NC}"
        virsh net-destroy default || true
        virsh net-undefine default || true

        # Create XML for the 'default' network using dynamic IP and Netmask
        echo -e "${CYAN}Defining and starting the new default network...${NC}"
        cat <<EOF > /tmp/default.xml
<network>
  <name>default</name>
  <uuid>$(uuidgen)</uuid>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:$(printf '%02X:%02X:%02X:%02X' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
EOF

        # Apply the network configuration
        virsh net-define /tmp/default.xml
        virsh net-start default
        virsh net-autostart default
    fi
fi

# Start dhcpcd if needed
echo -e "${CYAN}Starting dhcpcd...${NC}"
if ! dhcpcd; then
    echo -e "${RED}Failed to start dhcpcd. Please check the service status.${NC}"
fi

# Print success message after installation
echo -e "\n${GREEN}Successfully installed all of Dillacorn's Arch Linux chosen applications!${NC}"
else
    echo -e "\n${YELLOW}Skipping installation of Dillacorn's chosen Arch Linux applications.${NC}"
    exit 0
fi
