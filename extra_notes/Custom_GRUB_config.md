Notes From Repo: https://github.com/dillacorn/arch-i3-dots

# I've been annoyed by grub auto-selecting the newely install Arch kernal.

### Edit grub config

```sh
sudo micro /etc/default/grub
```

### add and/or edit save last boot kernal
```sh
# Save last selected kernal
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
```

### run this command to sync the changes
```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

#### I prefer this boot configuration because when a new kernal is released GRUB is selecting the new default Arch kernal even though I want to use the older custom "linux-tkg" kernal I selected previously...
