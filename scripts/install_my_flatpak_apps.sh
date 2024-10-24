#!/usr/bin/env bash

# Ensure the script is run with sudo
if [ -z "$SUDO_USER" ]; then
    echo "This script must be run with sudo!"
    exit 1
fi

# Flatpak installation and setup script

# Color Variables
CYAN_B='\033[1;96m'
YELLOW='\033[0;93m'
RED_B='\033[1;31m'
RESET='\033[0m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'

# Remote origin to use for installations
flatpak_origin='flathub'

# List of desktop apps to be installed (specified by app ID)
flatpak_apps=(
  'com.github.IsmaelMartinez.teams_for_linux'
  'dev.vencord.Vesktop'
  'org.telegram.desktop'
  'chat.simplex.simplex'
  'io.itch.itch'
  'com.heroicgameslauncher.hgl'
  'com.ultimaker.cura'
  'fr.handbrake.ghb'
  'com.dec05eba.gpu_screen_recorder'
  'com.obsproject.Studio'
  'com.obsproject.Studio.Plugin.NDI'
  'com.github.tchx84.Flatseal'
  'io.github.ungoogled_software.ungoogled_chromium'
)

# Check if Flatpak is installed; if not, install it via Pacman
if ! command -v flatpak &> /dev/null; then
  echo -e "${PURPLE}Flatpak is not installed. Installing Flatpak...${RESET}"
  sudo pacman -S --needed --noconfirm flatpak
fi

# Prompt the user to proceed with installation
echo -e "${CYAN_B}Would you like to install Dillacorn's chosen Flatpak applications? (y/n)${RESET}"
read -n 1 -r REPLY
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Flatpak setup and install canceled by the user...${RESET}"
  exit 0
fi

# Add Flathub repository if not already present
echo -e "${GREEN}Adding Flathub repository...${RESET}"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Update currently installed Flatpak apps
echo -e "${GREEN}Updating installed Flatpak apps...${RESET}"
sudo flatpak update -y

# Retry logic for Flatpak installation
install_flatpak_app() {
  local app="$1"
  local retries=3
  local count=0
  while ! flatpak list --app | grep -q "${app}"; do
    if [ $count -ge $retries ]; then
      echo -e "${RED_B}Failed to install ${app} after $retries attempts. Skipping...${RESET}"
      return 1
    fi
    echo -e "${GREEN}Installing ${app} (Attempt $((count + 1))/${retries})...${RESET}"
    
    # Install the Flatpak app and capture the exit code
    if sudo flatpak install -y "$flatpak_origin" "$app"; then
      echo -e "${GREEN}${app} installed successfully.${RESET}"
      break
    else
      install_status=$?
      if [ "$install_status" -eq 0 ]; then
        echo -e "${YELLOW}${app} is already installed. Skipping...${RESET}"
        break
      else
        echo -e "${RED_B}Failed to install ${app}. Retrying...${RESET}"
        count=$((count + 1))
        sleep 2
      fi
    fi
  done
}

# Install apps from the list
echo -e "${GREEN}Installing selected Flatpak apps...${RESET}"
for app in "${flatpak_apps[@]}"; do
  if ! flatpak list --app | grep -q "${app}"; then
    install_flatpak_app "${app}"
  else
    echo -e "${YELLOW}${app} is already installed. Skipping...${RESET}"
  fi
done

# Configure firewall rules for NDI
echo -e "${CYAN}Configuring firewall rules for NDI...${NC}"

# Add firewall rules for NDI (ports 5959-5969, 6960-6970, 7960-7970 for TCP and UDP, and 5353 for mDNS)
echo -e "${CYAN}Adding firewall rules...${NC}"
ufw allow 5353/udp
ufw allow 5959:5969/tcp
ufw allow 5959:5969/udp
ufw allow 6960:6970/tcp
ufw allow 6960:6970/udp
ufw allow 7960:7970/tcp
ufw allow 7960:7970/udp
ufw allow 5960/tcp

echo -e "${GREEN}Firewall rules for NDI configured successfully.${NC}"

echo -e "${PURPLE}Flatpak setup and installation complete.${RESET}"
