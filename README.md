# ⚡️ Zero-Latency macOS Command Center

This repository contains my `.config` dotfiles. It is a highly optimized, terminal-first macOS workflow that completely strips macOS of its window animations and relies on `skhd`, `yabai`, and `tmux` for instant, zero-latency context switching.

## ⚠️ Phase 1: The Hardcore Prerequisites (Apple Silicon)
To kill the hardcoded macOS animations, Yabai must inject code into the macOS WindowServer. **You cannot run this setup without disabling System Integrity Protection (SIP).** 

1. Boot your Mac into Recovery Mode.
2. Open the terminal from the top Utilities menu and run: `csrutil disable`
3. Reboot normally.
4. Open your terminal and set the Apple Silicon boot argument:
   `sudo nvram boot-args="-arm64e_preview_abi"`
5. **Reboot your Mac one more time.**

## 🚀 Phase 2: Installation
Clone this repository directly into your `~/.config` folder, then run the installer:

```bash
git clone [https://github.com/Jovial-Kanwadia/mac-os-dot-config.git](https://github.com/Jovial-Kanwadia/mac-os-dot-config.git) ~/.config
cd ~/.config
./install.sh
```
