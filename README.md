# `arch dilla.i3.files`
- **Preview Images**: [View Here](https://github.com/dillacorn/arch-i3-dots/tree/main/preview_images/preview_page.md)
- **Distro**: [Arch Linux](https://archlinux.org/)
- **Installation Method**: [archinstall](https://github.com/archlinux/archinstall)
- **File System**: ext4 (seperate root and home partition)
- **Repositories**: [core](https://archlinux.org/packages/?sort=&arch=any&repo=Core&q=&maintainer=&flagged=), [extra](https://archlinux.org/packages/?sort=&arch=any&repo=Extra&q=&maintainer=&flagged=), [multilib](https://archlinux.org/packages/?sort=&repo=Multilib&q=&maintainer=&flagged=) & [AUR](https://aur.archlinux.org/packages)
- **Bootloader**: [systemd-boot](https://github.com/ivandavidov/systemd-boot) ~ [configuration_tutorial_modification_guide](https://github.com/dillacorn/arch-i3-dots/blob/main/extra_notes/install_linux-tkg.md)
- **X11**: [i3-wm](https://github.com/i3/i3) ~ [config directory](https://github.com/dillacorn/arch-i3-dots/tree/main/config/i3)
- **Kernel**: [linux-tkg](https://github.com/Frogging-Family/linux-tkg) ~ BORE CPU Schedular + Full Tickless! [tutorial_install_guide](https://github.com/dillacorn/arch-i3-dots/blob/main/extra_notes/install_linux-tkg.md)
  - [Install linux-tkg on Arch](https://github.com/Frogging-Family/linux-tkg?tab=readme-ov-file#arch--derivatives)

---

## Keybinds: **DWM** Inspired
My keybinds (see [i3 config](https://github.com/dillacorn/arch-i3-dots/blob/main/config/i3/config)) are heavily inspired by [**suckless DWM**](https://dwm.suckless.org/). Before switching to i3, I used [**DWM Flexipatch**](https://github.com/bakkeby/dwm-flexipatch) by [bakkeby](https://github.com/bakkeby) — DWM was my first window manager.

---

## Wallpapers
- [Gruvbox Wallpapers](https://github.com/AngelJumbo/gruvbox-wallpapers) by [AngelJumbo](https://github.com/AngelJumbo)
- [Aesthetic Wallpapers](https://github.com/D3Ext/aesthetic-wallpapers) by [D3Ext](https://github.com/D3Ext)
- [Wallpapers](https://github.com/michaelScopic/Wallpapers) by [michaelScopic](https://github.com/michaelScopic)

---

## i3 Keybind Custom Scripts/Commands

Here are some of my custom keybinds from the i3 configuration:

- `Mod4+shift+q` = **Reload i3 config**  
  - Reloads the current i3 configuration to apply any changes.
  - Additionally randomizes wallpaper in `~/Pictures/wallpapers` directory. <- if you don't want this behavior modify the ([i3 config](https://github.com/dillacorn/arch-i3-dots/blob/main/config/i3/config)).
  
- `Mod4+shift+r` = **Rotate i3 mod navigation**  
  - Switches between `Mod1(alt)` and `Mod4(meta)` navigation using a script: [rotate mod script](https://github.com/dillacorn/arch-i3-dots/blob/main/config/i3/scripts/rotate_mod.sh).

- `Mod1+ctrl+shift+p` = **i3 Power Menu**  
  - Activates Selectable Power Menu script: [i3exit.sh](https://github.com/dillacorn/arch-i3-dots/blob/main/config/i3/scripts/i3exit.sh).
  - Escape(ESC) to cancel power menu.

- `Mod4+shift+t` = **i3 Theme Changer**
  - Launches a theme selector using Rofi: [View avaliable theme scripts](https://github.com/dillacorn/arch-i3-dots/tree/main/config/i3/themes).
  - You can easily add your own theme scripts to `~/.config/i3/themes`

- `Mod4+shift+w` = **Wallpaper Selector**
  - Opens `nitrogen`

- `mod4+shift+g` = **Capture a GIF**  
  - Starts a GIF recording with the script: [gif.sh](https://github.com/dillacorn/arch-i3-dots/blob/main/config/i3/scripts/gif.sh).  
  - **Repeat the keybind to finish recording!**
  - `gif_date_time.gif` saved in `~/Videos` directory.
  
- `Mod4+shift+s` = **maim screenshot**  
  - Takes a screenshot using maim and copies to clipboard.
  - `date_time.png` saved in `~/Pictures/screenshots` directory.

- `Mod4+shift+f` = **Flameshot screenshot**  
  - Takes a screenshot using Flameshot with more customization options.
  - `date_time.png` normally saved in `~/Pictures/screenshots` directory.

---

## i3 Navigation

Here are more example keybinds from my i3 config:

Let me preface `"Mod1"` can equal `"Mod1"` or `"Mod4"` depending on [rotate mod script](https://github.com/dillacorn/arch-i3-dots/blob/main/config/i3/scripts/rotate_mod.sh)

- `Mod1+shift+enter` = **Open Terminal**
  - Launches the terminal (default: Alacritty).

- `Mod1+p` = **Rofi Application Launcher**
  - Opens the Rofi app launcher for quick access to applications.

- `Mod4+ctrl+shift+l` = **Lock Screen**
  - Locks the screen using `i3lock`.

- `Mod1+shift+c` = **Close Window**
  - Closes the focused window.

- `Mod1+f` = **Toggle Floating**
  - Toggles between tiling and floating window layouts.

- `Mod1+shift+f` = **Toggle Fullscreen**
  - Toggles app focus ~ fullscreen.

- `Mod1+arrow_keys` = **Change Focus**
  - Switch between open windows.

- `Mod1+shift+arrow_keys` = **Move Windows**
  - Move window location within workspace.

- `Mod1+mouse_1` = **Move Floating Window**
  - Move Floating Window with your mouse.

- `Mod1+mouse_2` = **Resize Floating Window**
  - Resize Floating Window with your mouse.

- `Mod1+1` to `Mod1+9` = **Workspace Switching**  
  - Switches to workspaces 1 through 9.

- `Mod1+shift+1` to `Mod1+shift+9` = **Move Focused Window to Workspace**  
  - Moves the currently focused window to the specified workspace.
 
- `Mod1+ctrl+shift+arrows` = **Move Focused Workspace to Adjacent Monitor**  
  - Moves the currently focused workspace to an adjacent monitor.

---

### Installing i3-WM and Related Applications with Scripts

Install Arch Repo applications using [install script](https://github.com/dillacorn/arch-i3-dots/blob/main/scripts/install_my_arch_repo_apps.sh).

Install Arch AUR applications using [install script](https://github.com/dillacorn/arch-i3-dots/blob/main/scripts/install_my_aur_repo_apps.sh).

Install Flatpak applications using [install script](https://github.com/dillacorn/arch-i3-dots/blob/main/scripts/install_my_flatpak_apps.sh).

- Please feel free to modify scripts to remove and/or add applications of your preference for your own repository.

---

### P.S.
My goal is to learn as much as I can with X11, with the hope that this knowledge can eventually be applied to a separate repository using Sway-wm and/or Hyprland-wm.

At present, i3-wm seems more flexible (especially for gaming), but with ongoing developments, it's likely that the gap will eventually close, and we may all need to transition to a Wayland-based window manager.

### License
All code and notes are not under any formal license. If you find any of the scripts helpful, feel free to use, modify, publish, and distribute them to your heart's content. See https://unlicense.org/repo
