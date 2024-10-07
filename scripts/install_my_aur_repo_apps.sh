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
        makepkg -sirc --noconfirm
        cd ..
        rm -rf /tmp/yay  # Clean up the yay build directory
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
        yay -Syu --noconfirm  # Update system and AUR packages

        # Function to install a package and clean up its build directory
        install_package() {
            local package="\$1"
            yay -S --needed --noconfirm "\$package" 
            rm -rf /home/$SUDO_USER/.cache/yay/\$package  # Clean up the build directory for this package
        }

        # List of AUR packages to install with cleanup
        packages=(
            python2
            qimgv
            cava
            otpclient
            teams-for-linux-bin
            vibrantlinux
            vesktop
            spotify-bin
            obs-studio-bin
            handbrake-full
            heroic-games-launcher
            protonup-qt
            itch-setup-bin
            moonlight-qt
            sunshine
            cura-bin
            localsend-bin
            librewolf-bin
            ungoogled-chromium-bin
        )

        # Install each package and clean up afterward
        for package in "\${packages[@]}"; do
            install_package "\$package"
        done

        # Clean the package cache to free up space
        yay -Sc --noconfirm
EOF

    echo -e "\n${GREEN}Installation complete and disk space optimized!${NC}"
else
    echo -e "\n${YELLOW}Skipping installation of Dillacorn's chosen Arch AUR Linux applications.${NC}"
    exit 0
fi
