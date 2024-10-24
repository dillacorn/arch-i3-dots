Notes From Repo: https://github.com/dillacorn/arch-i3-dots

# install linux-tkg

**note**: *takes a while to build/compile and install*

*so in other words go do something else while it works its magic*

```sh
git clone https://github.com/Frogging-Family/linux-tkg.git
cd linux-tkg
makepkg -si
```

# if systemd-boot

list installed kernals

```sh
ls /boot/vmlinuz*
```
cd to systemd-boot kernal boot entries

```sh
cd /boot/loader/entries
ls
```

copy current `<date>`_`<time>`_`linux.conf` in folder

`sudo cp `<date>`_`<time>`_`linux.conf` linux-tkg-bore-`<version_#>`.conf`

`sudo micro linux-tkg-bore-`<version_#>`.conf`

will look something like this

# Created by: archinstall
# Created on: 2024-10-24_16-00-57
title   Arch Linux (linux)
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=6c524b73-40d8-454e-9fac-6952dc4f4ade zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs

edit the .conf (remove Created lines)

title   Arch Linux TKG `<version_#>`
linux   /vmlinuz-linux`<version_#>`-tkg-bore
initrd  /initramfs-linux`<version_#>`-tkg-bore.img
options root=PARTUUID=6c524b73-40d8-454e-9fac-6952dc4f4ade zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs

save and close

update bootloader

```sh
sudo bootctl update
```

reboot

"Arch Linux TKG `<version_#>`" should be in the list to choose now.
