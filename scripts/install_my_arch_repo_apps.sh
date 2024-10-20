#!/bin/bash

# Ensure the script is run with sudo/root privileges
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
    for pkg in ffmpeg avahi mpv peek cheese exiv2 audacity obs-studio krita shotcut telegram-desktop ncspot filezilla; do
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

    # Install other networking and security tools
    for pkg in wireguard-tools wireplumber openssh systemd-resolvconf bridge-utils qemu-guest-agent dnsmasq inetutils pipewire-pulse bluez; do
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

    # Enable libvirtd if it's installed
    echo -e "${CYAN}Configuring libvirt and networking...${NC}"
    if pacman -Qs libvirt > /dev/null; then
        echo -e "${CYAN}libvirt is installed. Enabling and starting libvirtd...${NC}"
        systemctl enable --now libvirtd

        # Verify if libvirtd started successfully
        if ! systemctl is-active --quiet libvirtd; then
            echo -e "${RED}libvirtd service failed to start. Please check the service status.${NC}"
            exit 1
        fi

        # Generate a unique UUID and random MAC address
        uuid=$(uuidgen)
        mac=$(printf '52:54:%02X:%02X:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))

        # Detect the current network interface, IP address, and netmask
        interface=$(ip route | grep '^default' | awk '{print $5}')
        ip_info=$(ip -o -4 addr show $interface | awk '{print $4}')
        current_ip=$(echo "$ip_info" | cut -d/ -f1)
        current_netmask=$(ipcalc "$ip_info" | grep Netmask | awk '{print $2}')

        # Define a default network IP and netmask to avoid conflicts
        default_network_ip="192.168.122.1"
        default_netmask="255.255.255.0"

        # Adjust if the current network overlaps with the default range
        if ipcalc -n "$ip_info" | grep -q "192.168.122.0"; then
            default_network_ip="10.0.0.1"
            default_netmask="255.255.255.0"
        elif ipcalc -n "$ip_info" | grep -q "10.0.0.0"; then
            default_network_ip="172.16.0.1"
            default_netmask="255.255.255.0"
        fi

        # Check if the 'default' network exists
        if ! virsh net-list --all | grep -q 'default'; then
            echo -e "${YELLOW}Network 'default' not found. Creating and starting the default network...${NC}"

            # Create XML for the 'default' network using dynamic IP and Netmask
            cat <<EOF > /tmp/default.xml
<network>
  <name>default</name>
  <uuid>$uuid</uuid>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='$mac'/>
  <ip address='$default_network_ip' netmask='$default_netmask'>
    <dhcp>
      <range start='${default_network_ip%.1}.2' end='${default_network_ip%.1}.254'/>
    </dhcp>
  </ip>
</network>
EOF

            virsh net-define /tmp/default.xml
            virsh net-start default
            virsh net-autostart default
            echo -e "${GREEN}Default network created and started.${NC}"
        else
            echo -e "${CYAN}Default network already defined and active.${NC}"
        fi
    else
        echo -e "${YELLOW}libvirt is not installed. Skipping libvirtd enablement.${NC}"
    fi

    # Print success message after installation
    echo -e "\n${GREEN}Successfully installed all of Dillacorn's Arch Linux chosen applications!${NC}"
else
    echo -e "\n${YELLOW}Skipping installation of Dillacorn's chosen Arch Linux applications.${NC}"
    exit 0
fi
