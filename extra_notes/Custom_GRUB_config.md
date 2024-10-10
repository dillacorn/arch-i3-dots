Notes From Repo: https://github.com/dillacorn/arch-i3-dots

# I've been annoyed by grub auto-selecting the newely install Debian kernal.

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

#### I prefer this boot configuration because when a new kernal is released GRUB is selecting the new default Arch kernal even though I want to use the older custom "linux-tkg" kernal I selected previously...
