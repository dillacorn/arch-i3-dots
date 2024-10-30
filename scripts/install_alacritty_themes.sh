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

# Check if the themes directory exists and is a valid git repository
if [ -d "$THEMES_DIR/.git" ]; then
    echo "The 'themes' directory already exists in $TARGET_DIR. Checking for updates..."
    cd "$THEMES_DIR" || exit 1
    
    # Fetch the latest changes from the remote repository
    git fetch origin main > /dev/null 2>&1
    
    # Compare local and remote commits
    LOCAL_COMMIT=$(git rev-parse HEAD)
    REMOTE_COMMIT=$(git rev-parse origin/main)
    
    if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
        echo "The 'themes' directory is already up-to-date."
    else
        echo "Updating 'themes' directory to the latest version..."
        git pull origin main
    fi
else
    # Clone the repository if the themes directory does not exist or is not a git repo
    echo "Cloning the Alacritty theme repository into $TARGET_DIR..."
    git clone "$REPO_URL" "$THEMES_DIR"
fi

# Confirm completion
echo "Finished running install_alacritty_themes.sh. 'themes' directory is up-to-date in $TARGET_DIR."
exit 0
