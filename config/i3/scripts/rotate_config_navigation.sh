#!/bin/bash

CONFIG="$HOME/.config/i3/config"

# Check if marked keybindings are currently using Mod1 or Mod4
if grep -q '# toggleable-mod Mod1' "$CONFIG"; then
    echo "Switching marked Mod1 to Mod4..."
    
    # Replace only the marked Mod1 bindings with Mod4
    sed -i 's/Mod1/# toggleable-mod Mod4/g' "$CONFIG"
    sed -i 's/# toggleable-mod Mod4/Mod4/g' "$CONFIG"
    
else
    echo "Switching marked Mod4 to Mod1..."
    
    # Replace only the marked Mod4 bindings with Mod1
    sed -i 's/Mod4/# toggleable-mod Mod1/g' "$CONFIG"
    sed -i 's/# toggleable-mod Mod1/Mod1/g' "$CONFIG"
fi

# Reload i3 configuration to apply changes
i3-msg reload
