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

# Check if yay is installed, if not, install it as the normal user
if ! command -v yay &> /dev/null; then
    echo -e "${YELLOW}'yay' is not installed. Installing yay...${NC}"
    sudo pacman -S --needed --noconfirm git base-devel

    # Temporarily become the non-root user to build yay
    sudo -u "$SUDO_USER" bash <<EOF
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd ..
        rm -rf /tmp/yay
EOF
fi

# Prompt for package installation
echo -e "\n${CYAN}Do you want to install Dillacorn's chosen Arch AUR Linux applications? [y/n]${NC}"

# Read a single character without requiring the Enter key
read -n1 -s choice

# Check user input
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo -e "\n${GREEN}Proceeding with installation of Dillacorn's chosen Arch AUR Linux applications...${NC}"
    
    # Temporarily become the non-root user to run yay for package installation
    sudo -u "$SUDO_USER" bash <<EOF
        yay -Syu --noconfirm
        yay -S --needed --noconfirm \
            qimgv \
            cava \
            otpclient \
            teams-for-linux \
            vibrantlinux \
            vesktop \
            spotify \
            obs-studio-git \
            handbrake-full \
            heroic-games-launcher \
            protonup-qt \
            itch-setup-bin \
            moonlight-qt \
            sunshine \
            cura-bin \
            localsend-bin \
            librewolf-bin \
            ungoogled-chromium
EOF

    echo -e "\n${GREEN}Installation complete!${NC}"
else
    echo -e "\n${YELLOW}Skipping installation of Dillacorn's chosen Arch AUR Linux applications.${NC}"
    exit 0
fi
