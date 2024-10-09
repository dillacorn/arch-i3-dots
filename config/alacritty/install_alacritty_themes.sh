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

# Ensure it goes past the first part
echo "Finished with alacritty-theme cloning step."

# Move the directory only if it doesn't already exist, otherwise prompt the user
if [ -d "themes" ]; then
    echo "The 'themes' directory already exists. Do you want to overwrite it? (y/n)"
    read -n 1 -s overwrite_themes
    echo
    if [[ "$overwrite_themes" == "y" || "$overwrite_themes" == "Y" ]]; then
        echo "Overwriting 'themes' directory..."
        rm -rf themes
        mv alacritty-theme themes
    else
        echo "Skipping moving of 'alacritty-theme' to 'themes'."
    fi
else
    mv alacritty-theme themes
fi

# Ensure it reaches the end
echo "Finished handling themes directory."
