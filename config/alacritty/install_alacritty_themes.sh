#!/bin/bash

# make executable:
# chmod +x install_alacritty_themes.sh

# Attempt to clone the repo, but don't fail the script if the directory already exists
if git clone https://github.com/alacritty/alacritty-theme; then
    echo "Repository cloned successfully."
else
    echo "Warning: alacritty-theme directory already exists or could not be cloned."
fi

# Move the directory only if it doesn't already exist
if [ ! -d "themes" ]; then
    mv alacritty-theme themes
else
    echo "Warning: 'themes' directory already exists and was not overwritten."
fi

# run command:
# ./install_alacritty_themes.sh
