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
LOCAL_REPO="alacritty-theme"

# Function to check if local repository is up to date with the remote
check_if_latest_version() {
    cd "$LOCAL_REPO" || return 1
    git fetch origin main > /dev/null 2>&1
    LOCAL_COMMIT=$(git rev-parse HEAD)
    REMOTE_COMMIT=$(git rev-parse origin/main)
    cd - > /dev/null 2>&1
    [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]
}

# Clone or update the alacritty-theme repository
if [ -d "$LOCAL_REPO" ]; then
    echo "'$LOCAL_REPO' directory already exists."
    
    if check_if_latest_version; then
        echo "The repository is already up-to-date. Skipping cloning."
    else
        echo "The repository is not up-to-date. Updating..."
        rm -rf "$LOCAL_REPO"
        git clone "$REPO_URL"
    fi
else
    git clone "$REPO_URL"
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

mv "$LOCAL_REPO" "$TARGET_DIR/themes"

# Confirm completion
echo "Finished running install_alacritty_themes.sh. 'themes' directory placed in $TARGET_DIR"
exit 0  # Explicitly return control
