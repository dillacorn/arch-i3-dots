#!/bin/bash

# Determine if the script is run with sudo
if [ -z "$SUDO_USER" ]; then
    # Not run with sudo
    TARGET_DIR="$HOME/.config/alacritty"
else
    # Run with sudo
    TARGET_DIR="/home/$SUDO_USER/.config/alacritty"
fi

# Attempt to clone the repo, but prompt the user if the directory already exists
if [ -d "alacritty-theme" ]; then
    echo "The 'alacritty-theme' directory already exists. Do you want to overwrite it? (y/n)"
    read -n 1 -s overwrite_alacritty_theme
    echo
    if [[ "$overwrite_alacritty_theme" == "y" || "$overwrite_alacritty_theme" == "Y" ]]; then
        echo "Overwriting 'alacritty-theme' directory..."
        rm -rf alacritty-theme
        git clone https://github.com/alacritty/alacritty-theme
        if [ $? -ne 0 ]; then
            echo "Error: Failed to clone the repository. Exiting."
            exit 1
        fi
    else
        echo "Skipping cloning of 'alacritty-theme'."
    fi
else
    git clone https://github.com/alacritty/alacritty-theme
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone the repository. Exiting."
        exit 1
    fi
fi

# Ensure the target directory exists
mkdir -p "$TARGET_DIR"

# Move 'alacritty-theme' to 'themes' within the target directory
if [ -d "$TARGET_DIR/themes" ]; then
    echo "Overwriting existing 'themes' directory in $TARGET_DIR..."
    rm -rf "$TARGET_DIR/themes"
fi

mv alacritty-theme "$TARGET_DIR/themes"

# Confirm completion
echo "Finished running install_alacritty_themes.sh. 'themes' directory placed in $TARGET_DIR"
exit 0  # Explicitly return control
