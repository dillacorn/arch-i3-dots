Notes From Repo: https://github.com/dillacorn/arch-i3-dots

For when FireFox isn't capable of the task.. or for just normal browsing with Manifest V3.. lame
FireFox is still better.. Using Librewolf as my main browser

# start here
```sh
flatpak install io.github.ungoogled_software.ungoogled_chromium
```

open "Ungoogled Chromium"

# flags

navigate to: `chrome://flags/`

change these flags:
* Handling of extension MIME type requests: `Always prompt for install` <- allows for **chrome-web-store** to be installed
* Disable search engine collection: `Enabled`
* Enable get*ClientRects() fingerprint deception: `Enabled`
* Enable Canvas::measureText() fingerprint deception: `Enabled`
* Enable Canvas image data fingerprint deception: `Enabled`
* Anonymize local IPs exposed by WebRTC: `Enabled`
* Preferred Ozone platform: `Wayland` <- If you're using **Wayland** session - **(Sway for example)**

# chrome web store fix

Make chrome web store work:

Open Extensions Page: `chrome://extensions/`

Enable `Developer mode` in the top right corner

Reboot Ungoogled Chromium

Navigate to : [`https://github.com/NeverDecaf/chromium-web-store`](https://github.com/NeverDecaf/chromium-web-store)

Go to release page and click on `Chromium.Web.Store.crx` to install it

Go install your extensions! -> [`https://chromewebstore.google.com/`](https://chromewebstore.google.com/)

# extensions

[`Chrome Show Tab Numbers`](https://chromewebstore.google.com/detail/chrome-show-tab-numbers/pflnpcinjbcfefgbejjfanemlgcfjbna)
[`uBlock Origin`](https://chromewebstore.google.com/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm)
[`LocalCDN`](https://chromewebstore.google.com/detail/localcdn/njdfdhgcmkocbgbhcioffdbicglldapd)
[`ClearURLs`](https://chromewebstore.google.com/detail/clearurls/lckanjgmijmafbedllaakclkaicjfmnk)
[`Privacy Badger`](https://chromewebstore.google.com/detail/privacy-badger/pkehgijcmpdhfbdbbnkijodmdjhbjlgp)
[`ScrollAnywhere`](https://chromewebstore.google.com/detail/scrollanywhere/jehmdpemhgfgjblpkilmeoafmkhbckhi)
[`Dark Reader`](https://chromewebstore.google.com/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh)
[`Key Jump keyboard navigation`](https://chromewebstore.google.com/detail/key-jump-keyboard-navigat/afdjhbmagopjlalgcjfclkgobaafamck)
[`Go Back With Backspace`](https://chromewebstore.google.com/detail/go-back-with-backspace/eekailopagacbcdloonjhbiecobagjci)
[`Bitwarden Password Manager`](https://chromewebstore.google.com/detail/bitwarden-password-manage/nngceckbapebfimnlniiiahkandclblb)
[`Google Translate`](https://chromewebstore.google.com/detail/google-translate/aapbdbdomjkkjkaonfhkkikfgjllcleb)
[`Honey`](https://chromewebstore.google.com/detail/honey-automatic-coupons-r/bmnlcjabgnpnenekpadlanbbkooimhnj)
[`Enhancer for YouTube`](https://chromewebstore.google.com/detail/enhancer-for-youtube/ponfpcnoihfmfllpaingbgckeeldkhle)
[`Return YouTube Dislike`](https://chromewebstore.google.com/detail/return-youtube-dislike/gebbhagfogifgggkldgodflihgfeippi)
[`DeArrow - Better Titles and Thumbnails`](https://chromewebstore.google.com/detail/dearrow-better-titles-and/enamippconapkdmgfgjchkhakpfinmaj)
[`Search by Image`](https://chromewebstore.google.com/detail/search-by-image/cnojnbdhbhnkbcieeekonklommdnndci)
[`DownThemAll!`](https://chromewebstore.google.com/detail/downthemall/nljkibfhlpcnanjgbnlnbjecgicbjkge)
[`FastForward`](https://chromewebstore.google.com/detail/fastforward/icallnadddjmdinamnolclfjanhfoafe)
[`SponsorBlock`](https://chromewebstore.google.com/detail/sponsorblock-for-youtube/mnjggcdmjocbbbhaepdhchncahnbgone)

# search engine

**search engine**: `(option #1)` - normally slower than brave

Name:
`disroot`

URL with %s in place of query
`https://search.disroot.org/search?q=%s`

**search engine**: `(option #2)` <- usually faster than disroot

Name:
`brave`

URL with %s in place of query
`https://search.brave.com/search?q=%s`

# Test Browser Security
https://browserleaks.com/webrtc

# custom dns server ~ optional

navigate to:
`Privacy and security` in settings

turn on:
`Use secure DNS`

add custom configured dns server from personal provider ~ I pay for nextdns ($2 a month)
### example dns server address

DNS-over-HTTPS: `https://dns.nextdns.io\xxxxxxx` 
