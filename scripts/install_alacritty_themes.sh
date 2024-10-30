#!/bin/bash

# Determine if the script is run with sudo
if [ -z "$SUDO_USER" ]; then
    # Not run with sudo
    TARGET_DIR="$HOME/.config/alacritty"
else
    # Run with sudo
    TARGET_DIR="/home/$SUDO_USER/.config/alacritty"
fi

REPO_URL="https://github.com/alacritty/alacritty-theme"
THEMES_DIR="$TARGET_DIR/themes"

# Function to check if the existing themes directory is up to date
check_if_latest_version() {
    cd "$THEMES_DIR" || return 1
    git fetch origin main > /dev/null 2>&1
    LOCAL_COMMIT=$(git rev-parse HEAD)
    REMOTE_COMMIT=$(git rev-parse origin/main)
    cd - > /dev/null 2>&1
    [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]
}

# Clone or update the themes directory in the target location
if [ -d "$THEMES_DIR/.git" ]; then
    echo "'themes' directory already exists in $TARGET_DIR."
    
    if check_if_latest_version; then
        echo "The themes directory is already up-to-date. Skipping cloning."
    else
        echo "The themes directory is not up-to-date. Updating..."
        rm -rf "$THEMES_DIR"
        git clone "$REPO_URL" "$THEMES_DIR"
    fi
else
    git clone "$REPO_URL" "$THEMES_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone the repository. Exiting."
        exit 1
    fi
fi

# Confirm completion
echo "Finished running install_alacritty_themes.sh. 'themes' directory placed in $TARGET_DIR"
exit 0  # Explicitly return control
