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

retry_command() {
    local retries=3
    local count=0
    until "$@"; do
        exit_code=$?
        count=$((count + 1))
        echo -e "\033[1;31mAttempt $count/$retries failed for command: $@\033[0m"  # Add this line
        if [ $count -lt $retries ]; then
            echo -e "\033[1;31mRetrying...\033[0m"
            sleep 1
        else
            echo -e "\033[1;31mCommand failed after $retries attempts. Exiting.\033[0m"
            return $exit_code
        fi
    done
    return 0
}

# Ensure script is being run from the correct directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Check if there's enough disk space (e.g., 1GB)
REQUIRED_SPACE_MB=1024
AVAILABLE_SPACE_MB=$(df / | tail -1 | awk '{print $4}')

if [ "$AVAILABLE_SPACE_MB" -lt "$REQUIRED_SPACE_MB" ]; then
    echo -e "\033[1;31mNot enough disk space (1GB required). Exiting.\033[0m"
    exit 1
fi

set -eu -o pipefail # fail on error and report it, debug all lines

# First confirmation
echo -e "\033[1;31mWARNING: This script will overwrite the following directories:\033[0m"
echo -e "\033[1;33m
- ~/.config/i3
- ~/.config/mc
- ~/.config/alacritty
- ~/.config/rofi
- ~/.config/dunst
- ~/.config/flameshot
- ~/.config/fastfetch
- ~/.config/xsettingsd
- ~/.config/gtk-3.0
- ~/.gtk-2.0
- /etc/X11/xinit/xinitrc
- ~/.Xresources\033[0m"
echo -e "\033[1;31mAre you sure you want to continue? This action CANNOT be undone.\033[0m"
echo -e "\033[1;32mPress 'y' to continue or 'n' to cancel. Default is 'yes' if Enter is pressed:\033[0m"

read -n 1 -r first_confirmation
echo

# If user presses Enter (no input), default to 'y'
if [[ "$first_confirmation" != "y" && "$first_confirmation" != "Y" && "$first_confirmation" != "" ]]; then
    echo -e "\033[1;31mInstallation canceled by user.\033[0m"
    exit 1
fi

# Second confirmation
echo -e "\033[1;31mThis is your last chance! Are you absolutely sure? (y/n)\033[0m"
read -n 1 -r second_confirmation
echo

if [[ "$second_confirmation" != "y" && "$second_confirmation" != "Y" && "$second_confirmation" != "" ]]; then
    echo -e "\033[1;31mInstallation canceled by user.\033[0m"
    exit 1
fi

# Adding pause before continuing
echo -e "\033[1;32mProceeding with the installation...\033[0m"
read -p "Press Enter to continue..."

# Set the home directory of the sudo user
HOME_DIR="/home/$SUDO_USER"

# Function to check and create directories if they don't exist
create_directory() {
    if [ ! -d "$1" ]; then
        echo -e "\033[1;33mCreating missing directory: $1\033[0m"
        retry_command mkdir -p "$1" || { echo -e "\033[1;31mFailed to create directory $1. Exiting.\033[0m"; exit 1; }
    else
        echo -e "\033[1;32mDirectory already exists: $1\033[0m"
    fi
    # Ensure correct ownership for non-root user ($SUDO_USER)
    retry_command chown $SUDO_USER:$SUDO_USER "$1" || { echo -e "\033[1;31mFailed to set ownership for $1. Exiting.\033[0m"; exit 1; }
    retry_command chmod 755 "$1" || { echo -e "\033[1;31mFailed to set permissions for $1. Exiting.\033[0m"; exit 1; }
}

# Install git if it's not already installed
echo -e "\033[1;34mUpdating package list and installing git...\033[0m"
if ! retry_command pacman -Syu --noconfirm; then
    echo -e "\033[1;31mFailed to update package list. Refreshing mirrors...\033[0m"
    retry_command sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
    echo -e "\033[1;34mMirrors refreshed. Retrying package list update...\033[0m"
    if ! retry_command pacman -Syu --noconfirm; then
        echo -e "\033[1;31mFailed to update package list after refreshing mirrors. Exiting.\033[0m"
        exit 1
    fi
fi

retry_command pacman -S --needed --noconfirm git || { echo -e "\033[1;31mFailed to install git. Exiting.\033[0m"; exit 1; }

# Clone the arch-i3-dots repository
if [ ! -d "$HOME_DIR/arch-i3-dots" ]; then
    echo -e "\033[1;34mCloning arch-i3-dots repository...\033[0m"
    retry_command git clone https://github.com/dillacorn/arch-i3-dots "$HOME_DIR/arch-i3-dots" || { echo -e "\033[1;31mFailed to clone arch-i3-dots repository. Exiting.\033[0m"; exit 1; }
    retry_command chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/arch-i3-dots"
else
    echo -e "\033[1;32march-i3-dots repository already exists in $HOME_DIR\033[0m"
fi

# Check for ipcalc availability and install if not available
if ! command -v ipcalc &>/dev/null; then
    echo -e "${CYAN}ipcalc is not installed. Installing ipcalc...${NC}"
    pacman -S --needed --noconfirm ipcalc || { echo -e "${RED}Failed to install ipcalc. Exiting.${NC}"; exit 1; }
else
    echo -e "${GREEN}ipcalc is already installed. Continuing...${NC}"
fi

# Make scripts executable
echo -e "\033[1;34mMaking ~/arch-i3-dots/scripts executable!\033[0m"
cd "$HOME_DIR/arch-i3-dots/scripts" || exit
retry_command chmod +x *
retry_command chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/arch-i3-dots/scripts"

# Run installation scripts for packages
echo -e "\033[1;34mRunning install_my_arch_repo_apps.sh...\033[0m"
retry_command ./install_my_arch_repo_apps.sh || { echo -e "\033[1;31minstall_my_arch_repo_apps.sh failed. Exiting.\033[0m"; exit 1; }
read -p "Press Enter to run the next script..."

echo -e "\033[1;34mRunning install_my_aur_repo_apps.sh...\033[0m"
retry_command ./install_my_aur_repo_apps.sh || { echo -e "\033[1;31minstall_my_aur_repo_apps.sh failed. Exiting.\033[0m"; exit 1; }
read -p "Press Enter to run the next script..."

echo -e "\033[1;34mRunning install_my_flatpak_apps.sh...\033[0m"
retry_command ./install_my_flatpak_apps.sh || { echo -e "\033[1;31minstall_my_flatpak_apps.sh failed. Exiting.\033[0m"; exit 1; }

# Ensure ~/.local/share/applications directory exists
create_directory "$HOME_DIR/.local/share/applications"

# Copy .desktop files into ~/.local/share/applications
echo -e "\033[1;34mCopying .desktop files to ~/.local/share/applications...\033[0m"
retry_command cp -r "$HOME_DIR/arch-i3-dots/local/share/applications/." "$HOME_DIR/.local/share/applications" || { echo -e "\033[1;31mFailed to copy .desktop files. Exiting.\033[0m"; exit 1; }

# Set correct permissions for ~/.local
retry_command chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/.local"
retry_command chmod u+rwx "$HOME_DIR/.local"
retry_command chmod u+rwx "$HOME_DIR/.local/share"
echo -e "\033[1;32mOwnership and permissions for ~/.local set correctly.\033[0m"

# Check if ComixCursors-White exists in ~/.local/share/icons
if [ ! -d "$HOME_DIR/.local/share/icons/ComixCursors-White" ]; then
    echo -e "\033[1;33mComixCursors-White not found in ~/.local/share/icons. Attempting to install... \033[0m"
    
    # Attempt to install ComixCursors-White
    retry_command pacman -S --needed --noconfirm comixcursors || { echo -e "\033[1;31mFailed to install ComixCursors-White. Exiting.\033[0m"; exit 1; }
    
    echo -e "\033[1;33mCopying ComixCursors-White to ~/.local/share/icons...\033[0m"
    retry_command cp -r /usr/share/icons/ComixCursors-White "$HOME_DIR/.local/share/icons" || { echo -e "\033[1;31mFailed to copy ComixCursors-White. Exiting.\033[0m"; exit 1; }
    retry_command chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/.local/share/icons/ComixCursors-White"
else
    echo -e "\033[1;32mComixCursors-White already exists in ~/.local/share/icons.\033[0m"
fi

# Apply cursor theme system-wide
echo -e "\033[1;34mSetting cursor theme to ComixCursors-White...\033[0m"
retry_command sudo bash -c 'cat > /usr/share/icons/default/index.theme <<EOF
[Icon Theme]
Inherits=ComixCursors-White
EOF'
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mFailed to set cursor theme. Exiting.\033[0m"
    exit 1
fi

# Apply cursor theme to Flatpak applications
echo -e "\033[1;34mApplying cursor theme to Flatpak applications...\033[0m"
retry_command flatpak override --user --env=GTK_CURSOR_THEME=ComixCursors-White
if [ $? -eq 0 ]; then
    echo -e "\033[1;32mCursor theme applied to Flatpak applications successfully.\033[0m"
else
    echo -e "\033[1;31mFailed to apply cursor theme to Flatpak applications.\033[0m"
    exit 1
fi

# Run the micro themes installation script
echo -e "\033[1;34mRunning install_micro_themes.sh...\033[0m"
retry_command ./install_micro_themes.sh || { echo -e "\033[1;31minstall_micro_themes.sh failed. Exiting.\033[0m"; exit 1; }

# Copy X11 configuration
create_directory "/etc/X11/xinit"
echo -e "\033[1;34mCopying X11 config...\033[0m"
retry_command cp "$HOME_DIR/arch-i3-dots/etc/X11/xinit/xinitrc" /etc/X11/xinit/ || { echo -e "\033[1;31mFailed to copy xinitrc. Exiting.\033[0m"; exit 1; }

# Convert xinitrc line endings to Unix format
echo -e "\033[1;34mConverting xinitrc line endings to Unix format...\033[0m"
retry_command dos2unix /etc/X11/xinit/xinitrc || { echo -e "\033[1;31mFailed to convert xinitrc line endings. Exiting.\033[0m"; exit 1; }
read -p "Press Enter to continue..."

# Edit libinput configuration
echo -e "\033[1;34mEditing libinput settings in /usr/share/X11/xorg.conf.d/40-libinput.conf...\033[0m"
if grep -q 'Identifier "libinput pointer catchall"' /usr/share/X11/xorg.conf.d/40-libinput.conf; then
    retry_command sed -i '/Identifier "libinput pointer catchall"/,/EndSection/ s|EndSection|    Option "AccelProfile" "flat"\nEndSection|' /usr/share/X11/xorg.conf.d/40-libinput.conf
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
retry_command cp "$HOME_DIR/arch-i3-dots/Xresources" "$HOME_DIR/.Xresources" || { echo -e "\033[1;31mFailed to copy .Xresources. Exiting.\033[0m"; exit 1; }

# Copy configuration files
config_dirs=("alacritty" "dunst" "i3" "rofi" "gtk-3.0" "flameshot" "fastfetch")

for config in "${config_dirs[@]}"; do
    echo -e "\033[1;32mCopying $config config...\033[0m"
    retry_command cp -r "$HOME_DIR/arch-i3-dots/config/$config" "$HOME_DIR/.config" || { echo -e "\033[1;31mFailed to copy $config config. Exiting.\033[0m"; exit 1; }
    retry_command chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/.config/$config"
done

# Copy mimeapps.list to ~/.config
echo -e "\033[1;34mCopying mimeapps.list to $HOME_DIR/.config...\033[0m"
retry_command cp "$HOME_DIR/arch-i3-dots/config/mimeapps.list" "$HOME_DIR/.config/" || { echo -e "\033[1;31mFailed to copy mimeapps.list. Exiting.\033[0m"; exit 1; }
retry_command chown $SUDO_USER:$SUDO_USER "$HOME_DIR/.config/mimeapps.list"

# Check if xsettingsd.conf exists and has been modified
if [ -f "$HOME_DIR/.config/xsettingsd/xsettingsd.conf" ]; then
    if ! diff -q "$HOME_DIR/.config/xsettingsd/xsettingsd.conf" "$HOME_DIR/arch-i3-dots/config/xsettingsd/xsettingsd.conf" > /dev/null; then
        echo -e "\033[1;33mxsettingsd.conf already exists and has been modified. Skipping overwrite.\033[0m"
    else
        echo -e "\033[1;34mCopying xsettingsd.conf to $HOME_DIR/.config/xsettingsd...\033[0m"
        retry_command cp "$HOME_DIR/arch-i3-dots/config/xsettingsd/xsettingsd.conf" "$HOME_DIR/.config/xsettingsd/" || { echo -e "\033[1;31mFailed to copy xsettingsd.conf. Exiting.\033[0m"; exit 1; }
        retry_command chown $SUDO_USER:$SUDO_USER "$HOME_DIR/.config/xsettingsd/xsettingsd.conf"
        retry_command chmod 644 "$HOME_DIR/.config/xsettingsd/xsettingsd.conf"
    fi
else
    # If xsettingsd.conf doesn't exist, copy it
    echo -e "\033[1;34mCopying xsettingsd.conf to $HOME_DIR/.config/xsettingsd...\033[0m"
    create_directory "$HOME_DIR/.config/xsettingsd"
    retry_command cp "$HOME_DIR/arch-i3-dots/config/xsettingsd/xsettingsd.conf" "$HOME_DIR/.config/xsettingsd/" || { echo -e "\033[1;31mFailed to copy xsettingsd.conf. Exiting.\033[0m"; exit 1; }
    retry_command chown $SUDO_USER:$SUDO_USER "$HOME_DIR/.config/xsettingsd/xsettingsd.conf"
    retry_command chmod 644 "$HOME_DIR/.config/xsettingsd/xsettingsd.conf"
fi

# Set permissions for .config
echo -e "\033[1;34mSetting permissions on configuration files and directories...\033[0m"
retry_command find "$HOME_DIR/.config/" -type d -exec chmod 755 {} +
retry_command find "$HOME_DIR/.config/" -type f -exec chmod 644 {} +

# Make i3-related scripts executable (recursively)
echo -e "\033[1;34mMaking i3-related scripts executable...\033[0m"
retry_command find "$HOME_DIR/.config/i3/scripts" -type f -exec chmod +x {} +

# Convert line endings to Unix format for i3 themes and scripts directories
echo -e "\033[1;34mConverting line endings to Unix format for i3 themes and scripts...\033[0m"
retry_command dos2unix $HOME_DIR/.config/i3/themes/./* || { echo -e "\033[1;31mFailed to convert line endings for i3 themes. Exiting.\033[0m"; exit 1; }
retry_command dos2unix $HOME_DIR/.config/i3/scripts/./* || { echo -e "\033[1;31mFailed to convert line endings for i3 scripts. Exiting.\033[0m"; exit 1; }

# Install Alacritty themes
echo -e "\033[1;34mRunning install_alacritty_themes.sh...\033[0m"
cd "$HOME_DIR/.config/alacritty" || exit
if [ -f "./install_alacritty_themes.sh" ]; then
    retry_command chmod +x ./install_alacritty_themes.sh
    retry_command ./install_alacritty_themes.sh || { echo -e "\033[1;31mAlacritty themes installation failed. Exiting.\033[0m"; exit 1; }
    echo -e "\033[1;32mAlacritty themes installed successfully.\033[0m"
else
    echo -e "\033[1;31minstall_alacritty_themes.sh not found. Exiting.\033[0m"
    exit 1
fi
read -p "Press Enter to continue..."

# Detect if running in a virtual machine
if systemd-detect-virt -q; then
    echo -e "\033[1;33mRunning in a virtual machine. Skipping GPU-specific configuration.\033[0m"
else
    # Detect GPU type and apply appropriate settings for AMD, Intel, or Nvidia users
    GPU_VENDOR=$(lspci | grep -i 'vga\|3d\|2d' | grep -i 'Radeon\|NVIDIA\|Intel\|Advanced Micro Devices')

    echo -e "\033[1;34mDetecting GPU vendor...\033[0m"

    if [ -z "$GPU_VENDOR" ]; then
        echo -e "\033[1;31mNo AMD, NVIDIA, or Intel GPU detected. Skipping GPU-specific configuration.\033[0m"
        exit 0
    fi

    if echo "$GPU_VENDOR" | grep -iq "Radeon"; then
        echo -e "\033[1;32mAMD GPU detected. Applying AMD-specific settings...\033[0m"
        
        # Ensure the linux-firmware package is installed for AMD GPUs
        retry_command sudo pacman -S --needed --noconfirm linux-firmware
        
        # Install AMD video decoding libraries (VA-API and VDPAU)
        retry_command sudo pacman -S --needed --noconfirm libva-mesa-driver mesa-vdpau lib32-mesa-vdpau

        # Check if vainfo and vdpauinfo are available, install if missing
        if ! command -v vainfo &> /dev/null; then
            echo -e "\033[1;34mInstalling libva-utils for VA-API support...\033[0m"
            retry_command sudo pacman -S --needed --noconfirm libva-utils
        fi

        if ! command -v vdpauinfo &> /dev/null; then
            echo -e "\033[1;34mInstalling vdpauinfo for VDPAU support...\033[0m"
            retry_command sudo pacman -S --needed --noconfirm vdpauinfo
        fi

        # Validate VA-API and VDPAU support
        echo -e "\033[1;34mValidating hardware acceleration (VA-API and VDPAU)...\033[0m"
        vainfo || echo -e "\033[1;31mVA-API not working properly.\033[0m"
        vdpauinfo || echo -e "\033[1;31mVDPAU not working properly.\033[0m"
        
        # Set the TTY console font to lat9w-16 in /etc/vconsole.conf
        echo -e "\033[1;34mSetting console font to lat9w-16 for AMD users in /etc/vconsole.conf...\033[0m"
        if ! grep -q "^FONT=lat9w-16" /etc/vconsole.conf; then
            echo 'FONT=lat9w-16' | sudo tee -a /etc/vconsole.conf
        fi

        # Optionally add any AMD-specific kernel parameters to GRUB (such as amdgpu.dc=1)
        if ! grep -q "amdgpu.dc=1" /etc/default/grub; then
            retry_command sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ amdgpu.dc=1"/' /etc/default/grub
            retry_command sudo grub-mkconfig -o /boot/grub/grub.cfg
        fi

    elif echo "$GPU_VENDOR" | grep -iq "NVIDIA"; then
        echo -e "\033[1;33mNVIDIA GPU detected. Applying NVIDIA-specific settings...\033[0m"
        
        # Ask user if they want to install the NVIDIA proprietary drivers
        echo -e "\033[1;34mDo you want to install the recommended NVIDIA proprietary drivers? (y/n)\033[0m"
        read -n 1 -s install_nvidia
        echo

        if [[ "$install_nvidia" == "y" || "$install_nvidia" == "Y" ]]; then
            if ! pacman -Q | grep -q "nvidia"; then
                echo -e "\033[1;34mInstalling NVIDIA proprietary drivers...\033[0m"
                retry_command sudo pacman -S --noconfirm lib32-nvidia-utils nvidia nvidia-utils nvidia-settings
                
                # Install video decoding libraries for NVIDIA
                retry_command sudo pacman -S --needed --noconfirm libva-vdpau-driver vdpauinfo
                
                # Validate VDPAU support
                echo -e "\033[1;34mValidating VDPAU hardware acceleration...\033[0m"
                vdpauinfo || echo -e "\033[1;31mVDPAU not working properly.\033[0m"
                
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

    elif echo "$GPU_VENDOR" | grep -iq "Intel"; then
        echo -e "\033[1;33mIntel GPU detected. Applying Intel-specific settings...\033[0m"
        
        # Ask user if they want to install the Intel driver
        echo -e "\033[1;34mDo you want to install the recommended Intel driver? (y/n)\033[0m"
        read -n 1 -s install_intel
        echo

        if [[ "$install_intel" == "y" || "$install_intel" == "Y" ]]; then
            if ! pacman -Q | grep -q "xf86-video-intel"; then
                echo -e "\033[1;34mInstalling Intel GPU driver...\033[0m"
                retry_command sudo pacman -S --noconfirm xf86-video-intel
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
fi

# Set alternatives for editor
echo -e "\033[1;94mSetting micro as default editor...\033[0m"
retry_command echo 'export EDITOR=/usr/bin/micro' >> "$HOME_DIR/.bashrc" || { echo -e "\033[1;31mFailed to set micro as default editor. Exiting.\033[0m"; exit 1; }

# Reload .bashrc after setting the default editor
retry_command source "$HOME_DIR/.bashrc" || { echo -e "\033[1;31mFailed to reload .bashrc. Exiting.\033[0m"; exit 1; }

# Set default file manager for directories
echo -e "\033[1;94mSetting pcmanfm as default GUI file manager...\033[0m"
retry_command xdg-mime default pcmanfm.desktop inode/directory

# Change ownership of all files in .config to the sudo user
echo -e "\033[1;32mConverting .config file ownership...\033[0m"
retry_command chown -R $SUDO_USER:$SUDO_USER "$HOME_DIR/.config"

# Add GTK2 theme and icon settings
retry_command echo 'include "'$HOME_DIR'/.gtkrc-2.0.mine"' > "$HOME_DIR/.gtkrc-2.0"
retry_command chown $SUDO_USER:$SUDO_USER "$HOME_DIR/.gtkrc-2.0"
retry_command chmod 644 "$HOME_DIR/.gtkrc-2.0"

retry_command echo -e 'gtk-theme-name="Materia-dark"\ngtk-icon-theme-name="Papirus-Dark"' > "$HOME_DIR/.gtkrc-2.0.mine"
retry_command chown $SUDO_USER:$SUDO_USER "$HOME_DIR/.gtkrc-2.0.mine"
retry_command chmod 644 "$HOME_DIR/.gtkrc-2.0.mine"

# Ensure ~/Pictures directory exists and correct permissions are set
create_directory "$HOME_DIR/Pictures/wallpapers"

# Copy wallpaper to ~/Pictures/wallpapers directory
echo -e "\033[1;94mCopying wallpaper...\033[0m"
retry_command cp "$HOME_DIR/arch-i3-dots/arch_geology.png" "$HOME_DIR/Pictures/wallpapers/" || { echo -e "\033[1;31mFailed to copy wallpaper. Exiting.\033[0m"; exit 1; }

# Check if Nitrogen is installed
if command -v nitrogen &> /dev/null; then
    echo -e "\033[1;32mNitrogen is installed. Configuring wallpaper directory...\033[0m"

    # Set the wallpaper directory
    WALLPAPER_DIR="$HOME_DIR/Pictures/wallpapers"

    # Ensure the directory exists
    create_directory "$WALLPAPER_DIR" || { echo -e "\033[1;31mFailed to ensure wallpaper directory. Exiting.\033[0m"; exit 1; }

    # Configuration file path
    CONFIG_FILE="$HOME_DIR/.config/nitrogen/nitrogen.cfg"
    
    # Create the configuration directory if it doesn't exist
    retry_command mkdir -p "$(dirname "$CONFIG_FILE")" || { echo -e "\033[1;31mFailed to create configuration directory. Exiting.\033[0m"; exit 1; }
    
    # Check if the configuration file already exists
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "\033[1;33mnitrogen.cfg already exists. Updating configuration...\033[0m"
        
        # Update or add geometry settings using sed
        if grep -q "\[geometry\]" "$CONFIG_FILE"; then
            retry_command sed -i "/\[geometry\]/,/^\[/ {s/posx=.*/posx=562/; s/posy=.*/posy=377/; s/sizex=.*/sizex=600/; s/sizey=.*/sizey=401/;}" "$CONFIG_FILE"
        else
            retry_command sed -i '$a [geometry]\nposx=562\nposy=377\nsizex=600\nsizey=401' "$CONFIG_FILE"
        fi
        
        # Update or add nitrogen settings using sed
        if grep -q "\[nitrogen\]" "$CONFIG_FILE"; then
            retry_command sed -i "/\[nitrogen\]/,/^\[/ {s/view=.*/view=icon/; s/recurse=.*/recurse=true/; s/sort=.*/sort=alpha/; s/icon_caps=.*/icon_caps=false/;}" "$CONFIG_FILE"

            # If dirs line exists, make sure the wallpaper directory is added
            if grep -q "^dirs=" "$CONFIG_FILE"; then
                if ! grep -q "$WALLPAPER_DIR" "$CONFIG_FILE"; then
                    retry_command sed -i "/^dirs=/ s|$|$WALLPAPER_DIR;|" "$CONFIG_FILE"
                fi
            else
                retry_command sed -i "$a dirs=$WALLPAPER_DIR;" "$CONFIG_FILE"
            fi
        else
            retry_command sed -i '$a [nitrogen]\nview=icon\nrecurse=true\nsort=alpha\nicon_caps=false\ndirs='$WALLPAPER_DIR';' "$CONFIG_FILE"
        fi

        # Ensure mode=zoom is at the end of the file using sed
        if ! grep -q "^mode=zoom$" "$CONFIG_FILE"; then
            retry_command sed -i '$a mode=zoom' "$CONFIG_FILE"
        fi
    else
        # Write default configuration to nitrogen.cfg if it doesn't exist
        cat <<EOL > "$CONFIG_FILE"
[geometry]
posx=562
posy=377
sizex=600
sizey=401

[nitrogen]
view=icon
recurse=true
sort=alpha
icon_caps=false
dirs=$WALLPAPER_DIR;
mode=zoom
EOL
        
        echo -e "\033[1;32mCreated nitrogen.cfg with settings for $WALLPAPER_DIR and mode=zoom.\033[0m"
    fi
else
    echo -e "\033[1;33mNitrogen is not installed. Skipping configuration...\033[0m"
fi

# Set the cursor theme in /usr/share/icons/default/index.theme
echo -e "\033[1;34mSetting cursor theme to ComixCursor-White...\033[0m"
retry_command sudo bash -c 'cat > /usr/share/icons/default/index.theme <<EOF
[Icon Theme]
Inherits=ComixCursor-White
EOF'
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mFailed to set cursor theme. Exiting.\033[0m"
    exit 1
fi
# Apply cursor theme to Flatpak applications
echo -e "\033[1;34mApplying cursor theme to Flatpak applications...\033[0m"
retry_command flatpak override --user --env=GTK_CURSOR_THEME=ComixCursors-White
if [ $? -eq 0 ]; then
    echo -e "\033[1;32mCursor theme applied to Flatpak applications successfully.\033[0m"
else
    echo -e "\033[1;31mFailed to apply cursor theme to Flatpak applications.\033[0m"
    exit 1
fi

# Enable and start NetworkManager
echo -e "\033[1;34mEnabling and starting NetworkManager...\033[0m"
retry_command sudo systemctl enable --now NetworkManager || { echo -e "\033[1;31mFailed to enable or start NetworkManager. Exiting.\033[0m"; exit 1; }

# List of directories to check/create
required_dirs=(
    "$HOME_DIR/.config"
    "$HOME_DIR/Videos"
    "$HOME_DIR/Pictures/wallpapers"
    "$HOME_DIR/Documents"
    "$HOME_DIR/Downloads"
    "$HOME_DIR/.local/share/icons"
)

# Create the required directories
for dir in "${required_dirs[@]}"; do
    create_directory "$dir"
done

# Fix permissions for Pictures directory
if [ -d "$HOME_DIR/Pictures" ]; then
    retry_command chown -R $SUDO_USER:$SUDO_USER $HOME_DIR/Pictures
fi

# Path to the non-root user's .bash_profile
BASH_PROFILE="/home/$SUDO_USER/.bash_profile"

# Check if .bash_profile exists, create if it doesn't
if [ ! -f "$BASH_PROFILE" ]; then
    echo "Creating $BASH_PROFILE..."
    touch "$BASH_PROFILE"
    chown $SUDO_USER:$SUDO_USER "$BASH_PROFILE"
fi

# Add fastfetch to bash_profile if it doesn't exist already
if ! grep -q "fastfetch" "$BASH_PROFILE"; then
    echo "Adding fastfetch to $BASH_PROFILE..."
    echo -e "\nfastfetch --config ~/.config/fastfetch/tty_compatible.jsonc" >> "$BASH_PROFILE"
    chown $SUDO_USER:$SUDO_USER "$BASH_PROFILE"
fi

# Add figlet Welcome message using the default font
if ! grep -q "figlet" "$BASH_PROFILE"; then
    echo "Adding figlet welcome to $BASH_PROFILE..."
    echo -e "\nfiglet \"Welcome \$USER!\"" >> "$BASH_PROFILE"
    chown $SUDO_USER:$SUDO_USER "$BASH_PROFILE"
fi

# Add i3-wm instruction
if ! grep -q "To start i3-wm" "$BASH_PROFILE"; then
    echo "Adding i3-wm instruction to $BASH_PROFILE..."
    echo -e "echo -e \"\\033[1;34mTo start i3-wm, type: \\033[1;31mstartx\\033[0m\"" >> "$BASH_PROFILE"
    chown $SUDO_USER:$SUDO_USER "$BASH_PROFILE"
fi

# Add random fun message generator to .bash_profile
if ! grep -q "add_random_fun_message" "$BASH_PROFILE"; then
    echo "Adding random fun message function to $BASH_PROFILE..."

    # Append the function definition to .bash_profile
    echo -e "\n# Function to generate a random fun message" >> "$BASH_PROFILE"
    echo -e "add_random_fun_message() {" >> "$BASH_PROFILE"
    echo -e "  fun_messages=(\"cacafire\" \"cmatrix\" \"aafire\" \"sl\" \"asciiquarium\" \"figlet TTY is cool\")" >> "$BASH_PROFILE"
    echo -e "  RANDOM_FUN_MESSAGE=\${fun_messages[\$RANDOM % \${#fun_messages[@]}]}" >> "$BASH_PROFILE"
    echo -e "  echo -e \"\\033[1;33mFor some fun, try running \\033[1;31m\$RANDOM_FUN_MESSAGE\\033[1;33m !\\033[0m\"" >> "$BASH_PROFILE"
    echo -e "}" >> "$BASH_PROFILE"

    # Append the function call to .bash_profile so it runs on every login
    echo -e "\n# Call the random fun message function on login" >> "$BASH_PROFILE"
    echo -e "add_random_fun_message" >> "$BASH_PROFILE"

    chown $SUDO_USER:$SUDO_USER "$BASH_PROFILE"
fi

echo "Changes have been applied to $BASH_PROFILE."

# Prompt the user to reboot the system after setup
echo -e "\033[1;34mSetup complete! Do you want to reboot now? (y/n)\033[0m"
read -n 1 -r reboot_choice
if [[ "$reboot_choice" == "y" || "$reboot_choice" == "Y" ]]; then
    echo -e "\033[1;34mRebooting...\033[0m"
    sleep 1
    retry_command reboot
else
    echo -e "\033[1;32mReboot skipped. You can reboot manually later.\033[0m"
    read -p "Press Enter to finish..."
fi
