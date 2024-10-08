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
  'com.github.IsmaelMartinez.teams_for_linux'             # Teams Work Client
  'dev.vencord.Vesktop'                                   # Discord Client
  'org.telegram.desktop'                                  # Telegram Client
  'com.spotify.Client'                                    # Music streaming
  'io.itch.itch'                                          # Install and play itch.io games
  'com.heroicgameslauncher.hgl'                           # Game Launcher
  'com.ultimaker.cura'                                    # 3D slicing
  'fr.handbrake.ghb'                                      # Video transcoder
  'com.github.tchx84.Flatseal'                            # Modify Flatpak Permissions
  'io.github.ungoogled_software.ungoogled_chromium'       # Degoogled Chromium-based browser
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

# Install apps from the list
echo -e "${GREEN}Installing selected Flatpak apps...${RESET}"
for app in "${flatpak_apps[@]}"; do
  if ! flatpak list --app | grep -q "${app}"; then
    echo -e "${GREEN}Installing ${app}...${RESET}"
    sudo flatpak install -y "$flatpak_origin" "$app"
  else
    echo -e "${YELLOW}${app} is already installed. Skipping...${RESET}"
  fi
done

echo -e "${PURPLE}Flatpak setup and installation complete.${RESET}"
