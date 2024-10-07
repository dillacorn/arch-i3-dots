Notes From Repo: https://github.com/dillacorn/arch-i3-dots

# Speed up Makepkg Parallelization for AUR applications!

`sudo micro /etc/makepkg.conf`

find `CTRL+f`

`#MAKEFLAGS="-j2"`

remove `#` and change

`MAKEFLAGS="-j$(nproc)"`

close & save file

## Enjoy!