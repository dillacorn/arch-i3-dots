#!/bin/bash

# Paths
config_file="$HOME/.config/i3/config"
backup_file="$HOME/.config/i3/config.bak"

# Backup the config if not already backed up
if [ ! -f "$backup_file" ]; then
    echo "Creating backup..."
    cp "$config_file" "$backup_file"
else
    echo "Backup already exists."
fi

# Function to switch to Mod4
switch_to_Mod4() {
    echo "Switching to Mod4..."
    sed -i '/# font for window titles and bars/,/#end of window title bars & borders section/! {/bar {/,/}/! s/Mod1/Mod4/g}' "$config_file"
    i3-msg reload
    echo "Switched to Mod4"
}

# Function to switch to Mod1 (revert from backup)
switch_to_Mod1() {
    echo "Switching to Mod1..."
    cp "$backup_file" "$config_file"
    i3-msg reload
    echo "Switched to Mod1"
}

# Check if Mod1 is active and switch to Mod4
if grep -q "Mod1" "$config_file"; then
    echo "Mod1 found in config, switching to Mod4..."
    switch_to_Mod4
else
    echo "Mod4 found in config, switching to Mod1..."
    switch_to_Mod1
fi
