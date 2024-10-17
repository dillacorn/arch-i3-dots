Notes From Repo: https://github.com/dillacorn/arch-i3-dots

### Edit grub config

```sh
sudo micro /etc/default/grub
```

### add and/or edit save last boot lines kernel
```sh
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
```

### if you have a high refresh rate display
```sh
GRUB_GFXMODE=1920x1080,240
```

### run this command to sync the changes
```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
