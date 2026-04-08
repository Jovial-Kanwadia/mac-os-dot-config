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

## 🧰 The `cx` Workspace Manager

`cx` is a workspace manager built for tmux. Source it in your shell:

```bash
source ~/.config/cx/cx.sh
```

### 🏗️ The Default Workspace Architecture
Whenever you trigger `cx` inside a project directory, it automatically creates a new Tmux session (e.g., `portfolio-c1`) and builds this exact layout in the background:
* **Window 1 (`nvim`):** Opens Neovim in the project root.
* **Window 2 (`shell`):** Opens a clean, isolated terminal for running servers/commands.
* **Window 3 (`opencode`):** Auto-launches your AI terminal coding agent.

---

### ⌨️ Core Commands

| Command | Description |
|---------|-------------|
| `cx` | Create a new workspace (auto-numbered) |
| `cx [N]` | Create workspace N (e.g., `cx 3` → `project-c3`) |
| `cxd` | Detach from current workspace |
| `cx1` - `cx9` | Switch to workspace 1-9 |
| `cxl` | List all workspaces for current project |
| `cxx1` - `cxx9` | Kill workspace 1-9 (with confirmation) |
| `cxf` | Fuzzy find project and open/create workspace |
| `cxs` | Fuzzy switch to any running session |
| `cxk` | Fuzzy kill multiple sessions (TAB to multi-select) |

---

### 🪄 Fuzzy Finder Features
This setup integrates `fzf` for zero-friction project hunting.

* `cxf` - Scans `~/programming` and `~/.config`. If sessions exist, asks to attach or create new.
* `cxs` - Switch to any running tmux session.
* `cxk` - Kill multiple sessions with TAB multi-select.

---

### ⚙️ Customizing Search Paths
Edit the `cxf()` function in `~/.config/cx/cx.sh` to change where `cxf` looks for projects:

```bash
local search_dirs=(
  "$HOME/programming"
  "$HOME/.config"
  "$HOME/your/custom/path"
)
```
