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
