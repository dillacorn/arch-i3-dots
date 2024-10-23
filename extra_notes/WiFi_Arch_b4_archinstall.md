# once arch .ISO is loaded

iwctl

list devices

station wlan0 scan

station wlan0 get-networks

### if get-networks shows no networks troubleshoot...

device wlan0 set-property Powered off

device wlan0 set-property Powered on

then

station wlan0 scan (again)

station wlan0 get-networks (again)

# SSID networks should now be displayed

station wlan0 connect "SSID_Name"

type password and connect!

Congrats you now should have internet!

# Test internet connection

ping archlinux.org