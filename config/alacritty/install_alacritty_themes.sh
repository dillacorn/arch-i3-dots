#!/bin/bash

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

# Always move 'alacritty-theme' to 'themes' directory without prompt
if [ -d "themes" ]; then
    echo "Overwriting 'themes' directory..."
    rm -rf themes
fi

mv alacritty-theme themes

# Add debug statement to confirm completion of this script
echo "Finished running install_alacritty_themes.sh"
exit 0  # Explicitly return control
