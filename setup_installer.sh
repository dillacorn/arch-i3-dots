#!/bin/bash
#################################################
##           Installation Instructions         ##
#################################################

# Step 1: Download the repository
# --------------------------------
# Open a terminal and run:
#   sudo pacman -S git
#   git clone https://github.com/dillacorn/arch-i3-dots

# Step 2: Run the installer
# -------------------------
# Navigate to the arch-i3-dots directory:
#   cd arch-i3-dots
# Make the installer executable and run it:
#   chmod +x setup_installer.sh
#   sudo ./setup_installer.sh
# Follow the on-screen instructions.

#################################################
##              End of Instructions            ##
#################################################

# Ensure the script is run with sudo
if [ -z "$SUDO_USER" ]; then
    echo "This script must be run with sudo!"
    exit 1
fi

set -eu -o pipefail # fail on error and report it, debug all lines

# Add a warning message for overwriting directories
echo -e "\033[1;31mWARNING: This script will overwrite the following directories:\033[0m"
echo -e "\033[1;33m
- ~/.config/i3
- ~/.config/mc
- ~/.config/alacritty
- ~/.config/rofi
- ~/.config/dunst
- ~/.config/gtk-3.0
- ~/.gtk-2.0
- /etc/X11/xinit/xinitrc
- ~/.Xresources\033[0m"
echo -e "\033[1;31mAre you sure you want to continue? This action CANNOT be undone.\033[0m"
echo -e "\033[1;32mPress 'y' to continue or 'n' to cancel.\033[0m"

# First confirmation
read -n 1 -r first_confirmation
echo

if [[ "$first_confirmation" != "y" && "$first_confirmation" != "Y" ]]; then
    echo -e "\033[1;31mInstallation canceled by user.\033[0m"
    exit 1
fi

# Second confirmation
echo -e "\033[1;31mThis is your last chance! Are you absolutely sure? (y/n)\033[0m"
read -n 1 -r second_confirmation
echo

if [[ "$second_confirmation" != "y" && "$second_confirmation" != "Y" ]]; then
    echo -e "\033[1;31mInstallation canceled by user.\033[0m"
    exit 1
fi

echo -e "\033[1;32mProceeding with the installation...\033[0m"

# Set the home directory of the sudo user
HOME_DIR="/home/$SUDO_USER"

# Check if required directories are present, and create them if not
echo -e "\033[1;34mChecking for required directories...\033[0m"

# List of directories to check/create
required_dirs=(
    "$HOME_DIR/.config"
    "$HOME_DIR/Videos"
    "$HOME_DIR/Pictures/wallpapers"
    "$HOME_DIR/Documents"
    "$HOME_DIR/Downloads"
)

# Loop through and create any missing directories
for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        echo -e "\033[1;33mCreating missing directory: $dir\033[0m"
        mkdir -p "$dir"
        chown $SUDO_USER:$SUDO_USER "$dir"
    else
        echo -e "\033[1;32mDirectory already exists: $dir\033[0m"
    fi
done

# Install git if it's not already installed
echo -e "\033[1;34mUpdating package list and installing git...\033[0m"
pacman -Syu --noconfirm
pacman -S --needed --noconfirm git

# Clone the arch-i3-dots repository into the home directory if it doesn't already exist
if [ ! -d "$HOME_DIR/arch-i3-dots" ]; then
    echo -e "\033[1;34mCloning arch-i3-dots repository...\033[0m"
    git clone https://github.com/dillacorn/arch-i3-dots "$HOME_DIR/arch-i3-dots"
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mFailed to clone the arch-i3-dots repository. Exiting.\033[0m"
        exit 1
    fi
    chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/arch-i3-dots"
else
    echo -e "\033[1;32march-i3-dots repository already exists in $HOME_DIR\033[0m"
fi

# Navigate to ~/arch-i3-dots/scripts and make scripts executable
echo -e "\033[1;34mMaking ~/arch-i3-dots/scripts executable!\033[0m"
cd "$HOME_DIR/arch-i3-dots/scripts" || exit
chmod +x *
chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/arch-i3-dots/scripts"

# Run install_my_arch_repo_apps.sh before proceeding
echo -e "\033[1;34mRunning install_my_arch_repo_apps.sh...\033[0m"
./install_my_arch_repo_apps.sh
if [ $? -ne 0 ]; then
    echo -e "\033[1;31minstall_my_arch_repo_apps.sh failed. Exiting.\033[0m"
    exit 1
fi

# Run install_my_aur_repo_apps.sh before proceeding
echo -e "\033[1;34mRunning install_my_aur_repo_apps.sh...\033[0m"
./install_my_aur_repo_apps.sh
if [ $? -ne 0 ]; then
    echo -e "\033[1;31minstall_my_aur_repo_apps.sh failed. Exiting.\033[0m"
    exit 1
fi

# Run install_my_flatpak_apps.sh before proceeding
echo -e "\033[1;34mRunning install_my_flatpak_apps.sh...\033[0m"
./install_my_flatpak_apps.sh
if [ $? -ne 0 ]; then
    echo -e "\033[1;31minstall_my_flatpak_apps.sh failed. Exiting.\033[0m"
    exit 1
fi

# Ensure ~/.local/share/applications directory exists
echo -e "\033[1;34mEnsuring ~/.local/share/applications directory exists...\033[0m"
mkdir -p "$HOME_DIR/.local/share/applications"

# Copy .desktop files into ~/.local/share/applications
echo -e "\033[1;34mCopying .desktop files to ~/.local/share/applications...\033[0m"
cp -r "$HOME_DIR/arch-i3-dots/local/share/applications/." "$HOME_DIR/.local/share/applications"

# Fix ownership and permissions for ~/.local, ~/.local/share, and ~/.local/share/applications
echo -e "\033[1;34mSetting ownership and permissions for ~/.local, ~/.local/share, and ~/.local/share/applications...\033[0m"

# Set ownership recursively for the entire .local directory
chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/.local"

# Check if the .local directory exists before setting permissions
if [ -d "$HOME_DIR/.local" ]; then
    chmod -R u+rwX "$HOME_DIR/.local"
fi

# Ensure ~/.local and ~/.local/share have correct permissions (including for Xorg)
chmod u+rwx "$HOME_DIR/.local"
chmod u+rwx "$HOME_DIR/.local/share"

echo -e "\033[1;32mOwnership and permissions for ~/.local, ~/.local/share, and ~/.local/share/applications set correctly.\033[0m"

echo -e "\033[1;34mRunning install_micro_themes.sh...\033[0m"
./install_micro_themes.sh
if [ $? -ne 0 ]; then
    echo -e "\033[1;31minstall_micro_themes.sh failed. Exiting.\033[0m"
    exit 1
fi

# Copy X11 configuration
echo -e "\033[1;34mCopying X11 config...\033[0m"
mkdir -p /etc/X11/xinit
cp "$HOME_DIR/arch-i3-dots/etc/X11/xinit/xinitrc" /etc/X11/xinit/
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mFailed to copy xinitrc. Exiting.\033[0m"
    exit 1
fi

# Edit /usr/share/X11/xorg.conf.d/40-libinput.conf
echo -e "\033[1;34mEditing libinput settings in /usr/share/X11/xorg.conf.d/40-libinput.conf...\033[0m"
if grep -q 'Identifier "libinput pointer catchall"' /usr/share/X11/xorg.conf.d/40-libinput.conf; then
    sed -i '/Identifier "libinput pointer catchall"/,/EndSection/ s|EndSection|    Option "AccelProfile" "flat"\nEndSection|' /usr/share/X11/xorg.conf.d/40-libinput.conf
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mFailed to update libinput configuration. Exiting.\033[0m"
        exit 1
    else
        echo -e "\033[1;32mSuccessfully updated libinput configuration.\033[0m"
    fi
else
    echo -e "\033[1;31mlibinput pointer section not found in /usr/share/X11/xorg.conf.d/40-libinput.conf. Exiting.\033[0m"
    exit 1
fi

# Copy .Xresources file
echo -e "\033[1;34mCopying .Xresources to $HOME_DIR...\033[0m"
cp "$HOME_DIR/arch-i3-dots/Xresources" "$HOME_DIR/.Xresources"
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mFailed to copy .Xresources. Exiting.\033[0m"
    exit 1
fi

# Copy other configuration files
config_dirs=("alacritty" "dunst" "i3" "rofi" "gtk-3.0")

for config in "${config_dirs[@]}"; do
    echo -e "\033[1;32mCopying $config config...\033[0m"
    cp -r "$HOME_DIR/arch-i3-dots/config/$config" "$HOME_DIR/.config"
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mFailed to copy $config config. Exiting.\033[0m"
        exit 1
    fi
    chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/.config/$config"
done

# Set permissions for .config
echo -e "\033[1;34mSetting permissions on configuration files and directories...\033[0m"
find "$HOME_DIR/.config/" -type d -exec chmod 755 {} +
find "$HOME_DIR/.config/" -type f -exec chmod 644 {} +

# Make specific i3-related scripts executable (recursively)
echo -e "\033[1;34mMaking i3-related scripts executable...\033[0m"
find "$HOME_DIR/.config/i3/scripts" -type f -exec chmod +x {} +

# Make all files in the themes folder executable (recursively)
echo -e "\033[1;34mMaking all files in $HOME_DIR/.config/i3/themes executable...\033[0m"
find "$HOME_DIR/.config/i3/themes" -type f -exec chmod +x {} +

# Make all files in the themes folder executable (recursively)
echo -e "\033[1;34mMaking all files in $HOME_DIR/.config/i3/themes executable...\033[0m"
find "$HOME_DIR/.config/i3/themes" -type f -exec chmod +x {} +

# Convert line endings to Unix format in the i3 themes and scripts directories
echo -e "\033[1;34mConverting line endings to Unix format for i3 themes and scripts...\033[0m"
dos2unix $HOME_DIR/.config/i3/themes/./*
dos2unix $HOME_DIR/.config/i3/scripts/./*

if [ $? -ne 0 ]; then
    echo -e "\033[1;31mFailed to convert line endings. Exiting.\033[0m"
    exit 1
fi

# Navigate to alacritty and make the installation script executable
echo -e "\033[1;34mRunning install_alacritty_themes.sh...\033[0m"
cd "$HOME_DIR/.config/alacritty" || exit

# Check if the script exists before trying to execute it
if [ -f "./install_alacritty_themes.sh" ]; then
    chmod +x ./install_alacritty_themes.sh
    ./install_alacritty_themes.sh
else
    echo -e "\033[1;31minstall_alacritty_themes.sh not found. Exiting.\033[0m"
    exit 1
fi

# Set alternatives for editor
echo -e "\033[1;94mSetting micro as default editor...\033[0m"
echo 'export EDITOR=/usr/bin/micro' >> ~/.bashrc
source ~/.bashrc

# Set default file manager for directories
echo -e "\033[1;94mSetting pcmanfm as default GUI file manager...\033[0m"
xdg-mime default pcmanfm.desktop inode/directory

# Change ownership of all files in .config to the sudo user
echo -e "\033[1;32mConverting .config file ownership...\033[0m"
chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/.config"

# Add GTK2 theme and icon settings
echo 'include "'$HOME_DIR'/.gtkrc-2.0.mine"' > "$HOME_DIR/.gtkrc-2.0"
chown $SUDO_USER:$SUDO_USER "$HOME_DIR/.gtkrc-2.0"
chmod 644 "$HOME_DIR/.gtkrc-2.0"

echo -e 'gtk-theme-name="Materia-dark"\ngtk-icon-theme-name="Papirus-Dark"' > "$HOME_DIR/.gtkrc-2.0.mine"
chown $SUDO_USER:$SUDO_USER "$HOME_DIR/.gtkrc-2.0.mine"
chmod 644 "$HOME_DIR/.gtkrc-2.0.mine"

# Copy wallpaper to ~/Pictures/wallpapers directory
echo -e "\033[1;94mCopying wallpaper...\033[0m"
cp "$HOME_DIR/arch-i3-dots/arch_geology.png" "$HOME_DIR/Pictures/wallpapers/"
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mFailed to copy wallpaper. Exiting.\033[0m"
    exit 1
fi
chown $SUDO_USER:$SUDO_USER "$HOME_DIR/Pictures/wallpapers/arch_geology.png"

# Set user-specific cursor theme
echo -e "\033[1;34mSetting user-specific cursor theme to ComixCursor-White...\033[0m"
mkdir -p "$HOME_DIR/.icons/default"
echo "[Icon Theme]
Inherits=ComixCursor-White" > "$HOME_DIR/.icons/default/index.theme"
chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/.icons"

# Update GTK settings for cursor theme
mkdir -p "$HOME_DIR/.config/gtk-3.0"
echo "[Settings]
gtk-cursor-theme-name = ComixCursor-White" > "$HOME_DIR/.config/gtk-3.0/settings.ini"
chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/.config/gtk-3.0"

# Set Xcursor theme in Xresources
echo "Xcursor.theme: ComixCursor-White" >> "$HOME_DIR/.Xresources"
xrdb -merge "$HOME_DIR/.Xresources"
chown $SUDO_USER:$SUDO_USER "$HOME_DIR/.Xresources"

# Enable and start NetworkManager
echo -e "\033[1;34mEnabling and starting NetworkManager...\033[0m"
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

# Prompt the user to reboot the system after setup
echo -e "\033[1;34mSetup complete! Do you want to reboot now? (y/n)\033[0m"
read -n 1 -r reboot_choice
if [[ "$reboot_choice" == "y" || "$reboot_choice" == "Y" ]]; then
    echo -e "\033[1;34mRebooting...\033[0m"
    sleep 2
    reboot
else
    echo -e "\033[1;32mReboot skipped. You can reboot manually later.\033[0m"
fi
