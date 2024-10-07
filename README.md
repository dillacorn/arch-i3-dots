# `arch dilla.i3.files`
- **Preview Images**: `TO BE ADDED`
- **Distro**: [Arch](https://archlinux.org/)
- **X11**: [i3-wm](https://github.com/i3/i3)
- **Kernel**: [linux-tkg](https://github.com/Frogging-Family/linux-tkg)
  - [Install linux-tkg on Arch](https://github.com/Frogging-Family/linux-tkg?tab=readme-ov-file#arch--derivatives)

---

## Keybinds: **DWM** Inspired
My keybinds (see [i3 config](https://github.com/dillacorn/arch-i3-dots/blob/main/config/i3/config)) are heavily inspired by [**suckless DWM**](https://dwm.suckless.org/). Before switching to i3, I used [**DWM Flexipatch**](https://github.com/bakkeby/dwm-flexipatch) by [bakkeby](https://github.com/bakkeby) — DWM was my first window manager.

---

## Wallpapers
- [Gruvbox Wallpapers](https://github.com/AngelJumbo/gruvbox-wallpapers) by [AngelJumbo](https://github.com/AngelJumbo)
- [Aesthetic Wallpapers](https://github.com/D3Ext/aesthetic-wallpapers) by [D3Ext](https://github.com/D3Ext)

---

## i3 Keybind Custom Scripts/Commands

Here are some of my custom keybinds from the i3 configuration:

- `mod4+shift+q` = **Reload i3 config**  
  - Reloads the current i3 configuration to apply any changes.
  - Additionally randomizes wallpaper in `~/Pictures/wallpapers` directory. <- if you don't want this behavior modify the ([i3 config](https://github.com/dillacorn/arch-i3-dots/blob/main/config/i3/config)).
  
- `mod4+shift+r` = **Rotate i3 mod navigation**  
  - Switches between `mod1(alt)` and `mod4(win/super)` navigation using a script: [rotate_config_navigation.sh](https://github.com/dillacorn/arch-i3-dots/blob/main/config/i3/scripts/rotate_config_navigation.sh).

- `mod1+ctrl+shift+p` = **i3 Power Menu**  
  - Activates Selectable Power Menu script: [i3exit.sh](https://github.com/dillacorn/arch-i3-dots/blob/main/config/i3/scripts/i3exit.sh).
  - Escape(ESC) to cancel power menu.

- `mod4+shift+t` = **i3 Theme Changer**
  - Launches a theme selector using Rofi: [View avaliable theme scripts](https://github.com/dillacorn/arch-i3-dots/tree/main/config/i3/themes).
  - You can easily add your own theme scripts to `~/.config/i3/themes`
  
- `mod4+shift+g` = **Capture a GIF**  
  - Starts a GIF recording with the script: [gif.sh](https://github.com/dillacorn/arch-i3-dots/blob/main/config/i3/scripts/gif.sh).  
  - **Repeat the keybind to finish recording!**
  - `gif_date_time.gif` saved in `~/Videos` directory.
  
- `mod4+shift+s` = **Grim screenshot**  
  - Takes a screenshot using Grim.
  - `date_time.jpg` saved in `~/Pictures` directory.

- `mod4+ctrl+shift+s` = **Flameshot screenshot**  
  - Takes a screenshot using Flameshot with more customization options.
  - `date_time.png` normally saved in `~/Pictures` directory.

---

## i3 Navigation

Here are more example keybinds from my i3 config:

Let me preface `"mod"` can equal `"mod1"` and/or `"mod4"` depending on [script navigation rotation](https://github.com/dillacorn/arch-i3-dots/blob/main/config/i3/scripts/rotate_config_navigation.sh)

- `mod+shift+enter` = **Open Terminal**
  - Launches the terminal (default: Alacritty).

- `mod+p` = **Rofi Application Launcher**
  - Opens the Rofi app launcher for quick access to applications.

- `mod4+ctrl+shift+l` = **Lock Screen**
  - Locks the screen using `i3lock`.

- `mod+shift+c` = **Close Window**
  - Closes the focused window.

- `mod+f` = **Toggle Floating**
  - Toggles between tiling and floating window layouts.

- `mod+shift+f` = **Toggle Fullscreen**
  - Toggles app focus ~ fullscreen.

- `mod+arrow_keys` = **Change Focus**
  - Switch between open windows.

- `mod+shift+arrow_keys` = **Move Windows**
  - Move window location within workspace.

- `mod+mouse_1` = **Move Floating Window**
  - Move Floating Window with your mouse.

- `mod+mouse_2` = **Resize Floating Window**
  - Resize Floating Window with your mouse.

- `mod+1` to `mod+9` = **Workspace Switching**  
  - Switches to workspaces 1 through 9.

- `mod+shift+1` to `mod+shift+9` = **Move Focused Window to Workspace**  
  - Moves the currently focused window to the specified workspace.

---

### Installing i3-WM and Related Applications with Scripts

Install Arch Repo applications using [install script](https://github.com/dillacorn/arch-i3-dots/blob/main/scripts/install_my_arch_repo_apps.sh). This script installs essential tools and applications like i3-wm, Rofi, Dunst, and more.

Install Arch AUR applications using [install script](https://github.com/dillacorn/arch-i3-dots/blob/main/scripts/install_my_aur_repo_apps.sh). This script installs essential applications like ungoogled-chromium, spotify, obs, and more.

---

### P.S.
My goal is to learn as much as I can with X11, with the hope that this knowledge can eventually be applied to a separate repository using Sway-wm and/or Hyperland-wm.

At present, i3-wm seems more flexible (especially for gaming), but with ongoing developments, it's likely that the gap will eventually close, and we may all need to transition to a Wayland-based window manager.

### License
All code and notes are not under any formal license. If you find any of the scripts helpful, feel free to use, modify, publish, and distribute them to your heart's content. See https://unlicense.org/repo