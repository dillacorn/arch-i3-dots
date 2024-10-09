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

# Function to check and create directories if they don't exist
create_directory() {
    if [ ! -d "$1" ]; then
        echo -e "\033[1;33mCreating missing directory: $1\033[0m"
        mkdir -p "$1"
        chown $SUDO_USER:$SUDO_USER "$1"
    else
        echo -e "\033[1;32mDirectory already exists: $1\033[0m"
    fi
}

# List of directories to check/create
required_dirs=(
    "$HOME_DIR/.config"
    "$HOME_DIR/Videos"
    "$HOME_DIR/Pictures/wallpapers"
    "$HOME_DIR/Documents"
    "$HOME_DIR/Downloads"
)

# Create the required directories
for dir in "${required_dirs[@]}"; do
    create_directory "$dir"
done

# Install git if it's not already installed
echo -e "\033[1;34mUpdating package list and installing git...\033[0m"
if ! pacman -Syu --noconfirm; then
    echo -e "\033[1;31mFailed to update package list. Refreshing mirrors...\033[0m"
    sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
    echo -e "\033[1;34mMirrors refreshed. Retrying package list update...\033[0m"
    if ! pacman -Syu --noconfirm; then
        echo -e "\033[1;31mFailed to update package list after refreshing mirrors. Exiting.\033[0m"
        exit 1
    fi
fi

# Install git if it's not already installed
if ! pacman -S --needed --noconfirm git; then
    echo -e "\033[1;31mFailed to install git. Exiting.\033[0m"
    exit 1
fi

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
create_directory "$HOME_DIR/.local/share/applications"

# Copy .desktop files into ~/.local/share/applications
echo -e "\033[1;34mCopying .desktop files to ~/.local/share/applications...\033[0m"
cp -r "$HOME_DIR/arch-i3-dots/local/share/applications/." "$HOME_DIR/.local/share/applications"

# Fix ownership and permissions for ~/.local, ~/.local/share, and ~/.local/share/applications
echo -e "\033[1;34mSetting ownership and permissions for ~/.local, ~/.local/share, and ~/.local/share/applications...\033[0m"

# Set ownership recursively for the entire .local directory
chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/.local"

# Ensure ~/.local and ~/.local/share have correct permissions
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
create_directory "/etc/X11/xinit"
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

# Copy mimeapps.list to ~/.config
echo -e "\033[1;34mCopying mimeapps.list to $HOME_DIR/.config...\033[0m"
cp "$HOME_DIR/arch-i3-dots/config/mimeapps.list" "$HOME_DIR/.config/"
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mFailed to copy mimeapps.list. Exiting.\033[0m"
    exit 1
fi
chown $SUDO_USER:$SUDO_USER "$HOME_DIR/.config/mimeapps.list"

# Set permissions for .config
echo -e "\033[1;34mSetting permissions on configuration files and directories...\033[0m"
find "$HOME_DIR/.config/" -type d -exec chmod 755 {} +
find "$HOME_DIR/.config/" -type f -exec chmod 644 {} +

# Make specific i3-related scripts executable (recursively)
echo -e "\033[1;34mMaking i3-related scripts executable...\033[0m"
find "$HOME_DIR/.config/i3/scripts" -type f -exec chmod +x {} +

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

# Check if the install_alacritty_themes.sh script exists before executing it
if [ -f "./install_alacritty_themes.sh" ]; then
    chmod +x ./install_alacritty_themes.sh
    ./install_alacritty_themes.sh

    # Explicitly check the exit status and continue the script
    if [ $? -eq 0 ]; then
        echo -e "\033[1;32mAlacritty themes installed successfully.\033[0m"
    else
        echo -e "\033[1;31mAlacritty themes installation failed. Exiting.\033[0m"
        exit 1
    fi

    # After running the Alacritty script, ensure continuation
    echo -e "\033[1;34mContinuing with GPU detection...\033[0m"
else
    echo -e "\033[1;31minstall_alacritty_themes.sh not found. Exiting.\033[0m"
    exit 1
fi

# Continue with the rest of the script

# Detect GPU type and apply appropriate settings for AMD, Intel, or Nvidia users
GPU_VENDOR=$(lspci | grep -i 'vga\|3d\|2d' | grep -E 'AMD|NVIDIA|Intel' | awk '{print $1,$5}')

echo -e "\033[1;34mDetecting GPU vendor...\033[0m"

if [ -z "$GPU_VENDOR" ]; then
    echo -e "\033[1;31mNo GPU detected or unrecognized GPU. Skipping GPU-specific configuration.\033[0m"
    exit 0
fi

if echo "$GPU_VENDOR" | grep -q "AMD"; then
    echo -e "\033[1;32mAMD GPU detected. Applying AMD-specific settings...\033[0m"
    
    # Ensure the linux-firmware package is installed for AMD GPUs
    sudo pacman -S --needed --noconfirm linux-firmware

    # Ask user if they want to install the AMDGPU driver
    echo -e "\033[1;34mDo you want to install the recommended AMDGPU driver? (y/n)\033[0m"
    echo -e "\033[1;33mInstalling this driver is recommended for better performance and full compatibility with your AMD GPU.\033[0m"
    read -n 1 -s install_amdgpu
    echo
    
    if [[ "$install_amdgpu" == "y" || "$install_amdgpu" == "Y" ]]; then
        if ! pacman -Q | grep -q "xf86-video-amdgpu"; then
            echo -e "\033[1;34mInstalling AMDGPU driver...\033[0m"
            sudo pacman -S --noconfirm xf86-video-amdgpu
            if [ $? -ne 0 ]; then
                echo -e "\033[1;31mFailed to install AMDGPU driver. Exiting.\033[0m"
                exit 1
            fi
        else
            echo -e "\033[1;32mAMDGPU driver already installed.\033[0m"
        fi
    else
        echo -e "\033[1;33mSkipping AMDGPU driver installation as per user choice.\033[0m"
    fi

    # Set the TTY console font to lat9w-16 in /etc/vconsole.conf
    echo -e "\033[1;34mSetting console font to lat9w-16 for AMD users in /etc/vconsole.conf...\033[0m"
    if ! grep -q "^FONT=lat9w-16" /etc/vconsole.conf; then
        echo 'FONT=lat9w-16' >> /etc/vconsole.conf
    fi

    # Optionally add any AMD-specific kernel parameters to GRUB (such as amdgpu.dc=1)
    if ! grep -q "amdgpu.dc=1" /etc/default/grub; then
        sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ amdgpu.dc=1"/' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        if [ $? -eq 0 ]; then
            echo -e "\033[1;32mAMD-specific kernel parameters added to GRUB.\033[0m"
        else
            echo -e "\033[1;31mError updating GRUB configuration. Please check the output above for details.\033[0m"
        fi
    fi

elif echo "$GPU_VENDOR" | grep -q "NVIDIA"; then
    echo -e "\033[1;33mNVIDIA GPU detected. Applying NVIDIA-specific settings...\033[0m"
    
    # Ask user if they want to install the NVIDIA proprietary drivers
    echo -e "\033[1;34mDo you want to install the recommended NVIDIA proprietary drivers? (y/n)\033[0m"
    read -n 1 -s install_nvidia
    echo

    if [[ "$install_nvidia" == "y" || "$install_nvidia" == "Y" ]]; then
        if ! pacman -Q | grep -q "nvidia"; then
            echo -e "\033[1;34mInstalling NVIDIA proprietary drivers...\033[0m"
            sudo pacman -S --noconfirm nvidia nvidia-utils
            if [ $? -ne 0 ]; then
                echo -e "\033[1;31mFailed to install NVIDIA proprietary drivers. Exiting.\033[0m"
                exit 1
            fi
        else
            echo -e "\033[1;32mNVIDIA proprietary drivers already installed.\033[0m"
        fi
    else
        echo -e "\033[1;33mSkipping NVIDIA driver installation as per user choice.\033[0m"
    fi

elif echo "$GPU_VENDOR" | grep -q "Intel"; then
    echo -e "\033[1;33mIntel GPU detected. Applying Intel-specific settings...\033[0m"
    
    # Ask user if they want to install the Intel driver
    echo -e "\033[1;34mDo you want to install the recommended Intel driver? (y/n)\033[0m"
    read -n 1 -s install_intel
    echo

    if [[ "$install_intel" == "y" || "$install_intel" == "Y" ]]; then
        if ! pacman -Q | grep -q "xf86-video-intel"; then
            echo -e "\033[1;34mInstalling Intel GPU driver...\033[0m"
            sudo pacman -S --noconfirm xf86-video-intel
            if [ $? -ne 0 ]; then
                echo -e "\033[1;31mFailed to install Intel driver. Exiting.\033[0m"
                exit 1
            fi
        else
            echo -e "\033[1;32mIntel driver already installed.\033[0m"
        fi
    else
        echo -e "\033[1;33mSkipping Intel driver installation as per user choice.\033[0m"
    fi

else
    echo -e "\033[1;31mNo AMD, NVIDIA, or Intel GPU detected. Skipping GPU-specific configuration.\033[0m"
fi

# Set alternatives for editor
echo -e "\033[1;94mSetting micro as default editor...\033[0m"
echo 'export EDITOR=/usr/bin/micro' >> ~/.bashrc
source ~/.bashrc

# Reload .bashrc after setting the default editor
source "$HOME_DIR/.bashrc"

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

# Ensure ~/Pictures directory exists and correct permissions are set
create_directory "$HOME_DIR/Pictures/wallpapers"

# Copy wallpaper to ~/Pictures/wallpapers directory
echo -e "\033[1;94mCopying wallpaper...\033[0m"
cp "$HOME_DIR/arch-i3-dots/arch_geology.png" "$HOME_DIR/Pictures/wallpapers/"
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mFailed to copy wallpaper. Exiting.\033[0m"
    exit 1
fi

# Set the cursor theme in /usr/share/icons/default/index.theme
echo -e "\033[1;34mSetting cursor theme to ComixCursor-White...\033[0m"
sudo bash -c 'cat > /usr/share/icons/default/index.theme <<EOF
[Icon Theme]
Inherits=ComixCursor-White
EOF'
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mFailed to set cursor theme. Exiting.\033[0m"
    exit 1
fi

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
