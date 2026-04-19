# Dotfiles

A terminal-first macOS development environment built around tmux, Neovim (0.11+), and a custom workspace manager.
Peak Feature — Uses yabai + skhd to eliminate ugly ass macOS window animations.

## What's Included

| Component | Purpose |
|-----------|---------|
| **Neovim** | Primary editor — native LSP, Treesitter, Telescope, Harpoon, image rendering |
| **tmux** | Session manager — Tokyo Night theme, vim-tmux-navigator, session persistence |
| **Kitty** | GPU-accelerated terminal — kitty graphics protocol, transparency, animated cursor |
| **yabai** | Tiling window manager — disables macOS animations via scripting addition |
| **skhd** | Global hotkeys — instant app/window switching |
| **Starship** | Cross-shell prompt with git, language, and docker context |
| **cx** | Custom tmux workspace manager — create, switch, kill, fuzzy-find sessions |
| **cp** | Competitive programming toolkit — compile, run, judge, scaffold problems |
| **OpenCode** | AI coding assistant (Gemini/OpenRouter) with custom agents |
| **Git hooks** | Global AI commit message generator using Gemini |
| **Sioyek** | Vim-keybind PDF reader with dark theme |
| **ds.sh** | Offline documentation browser using dedoc + fzf |

## Prerequisites

- **macOS** on Apple Silicon (ARM64)
- **zsh** as default shell (macOS default — this setup does **not** support bash, fish, or other shells)
- **SIP must be disabled** for yabai scripting addition — follow the [yabai wiki](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection)
- **Xcode Command Line Tools**: `xcode-select --install`

## Backup Your Existing Config

If you already have a `~/.config` directory, back it up first:

```bash
# Create a timestamped backup
mv ~/.config ~/.config.backup.$(date +%Y%m%d-%H%M%S)
```

To **restore** your old config if you don't like this one:

```bash
# Remove this config
rm -rf ~/.config

# Restore your backup (use the actual timestamp from above)
mv ~/.config.backup.XXXXXXXX-XXXXXX ~/.config
```

## Installation

```bash
git clone https://github.com/Jovial-Kanwadia/mac-os-dot-config.git ~/.config
cd ~/.config
chmod +x install.sh
./install.sh
```

The script handles everything: Homebrew, CLI tools, casks, fonts, shell plugins, tmux plugins, Neovim plugin bootstrap, Rust toolchain, Go tools, Bun, competitive programming headers, git hooks, and zshrc integration.

After the script completes:

```bash
source ~/.zshrc
```

## Architecture

```
                    ┌─────────────────────────────────────┐
                    │           skhd (Global Hotkeys)     │
                    │                                     │
                    │  Ctrl+1 → Kitty + Window 1 (nvim)   │
                    │  Ctrl+2 → Kitty + Window 2 (shell)  │
                    │  Ctrl+3 → Kitty + Window 3(opencode)│
                    │  Ctrl+4 → Brave Browser             │
                    └─────────────────────────────────────┘
                                              │
                    ┌─────────────────────────┴────────────┐
                    │           Kitty (Terminal)           │
                    │  ┌─────────────────────────────┐     │
                    │  │     tmux (Session Manager)  │     │
                    │  │                             │     │
                    │  │  Window 1: nvim             │     │
                    │  │  Window 2: shell            │     │
                    │  │  Window 3: opencode         │     │
                    │  └─────────────────────────────┘     │
                    └──────────────────────────────────────┘

    cx (Workspace Manager)          cp (Competitive Programming)
    ┌──────────────────────┐        ┌──────────────────────────┐
    │ cxf → fuzzy project  │        │ cpn  → scaffold problem  │
    │ cxs → switch session │        │ cpr  → compile & judge   │
    │ cxk → kill session   │        │ cpnf → fuzzy open        │
    │ cx1-9 → jump to WS   │        │ cpnd → delete problems   │
    └──────────────────────┘        └──────────────────────────┘
```

## Keybindings

### Neovim

Leader key: `<Space>`

#### General

| Key | Action |
|-----|--------|
| `j`, `k` | Navigate wrapped lines |
| `<C-d>`, `<C-u>` | Scroll down/up (cursor centered) |
| `n`, `N` | Next/previous search match (centered) |
| `<CR>` | Insert newline below |
| `-` | Open Oil file explorer |
| `v` + `y` | Yank to system clipboard |
| `<leader>e` | Show diagnostic float |
| `<leader>fc` | Show all commands |
| `<leader>ds` | Open doc search (ds.sh) in split |
| `<leader>DK` | DevDocs keyword search under cursor |

#### Telescope

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | List buffers |
| `<leader>fh` | Search help tags |
| `<leader>fr` | Recent files |

#### Harpoon

| Key | Action |
|-----|--------|
| `<leader>a` | Add current file |
| `<leader>hh` | Toggle harpoon menu |
| `<leader>hn` | Next mark |
| `<leader>hp` | Previous mark |
| `<leader>1-4` | Jump to mark 1-4 |
| `<leader>hm` | Show marks in Telescope |

#### LSP (on attach)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `gi` | Go to implementation |
| `gt` | Go to type definition |
| `K` | Show hover documentation |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>lf` | Format document |
| `[d`, `]d` | Previous/next diagnostic |

#### Git

| Key | Action |
|-----|--------|
| `]h`, `[h` | Next/previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hu` | Undo stage hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line (popup) |
| `<leader>tb` | Toggle inline blame |

#### Diffview

| Key | Action |
|-----|--------|
| `<leader>gd` | Toggle diff view |
| `<leader>gh` | File history |

#### Notes / Images (Markdown)

| Key | Action |
|-----|--------|
| `<leader>pi` | Insert image from attachments (with preview) |
| `<leader>pp` | Paste image from clipboard (via pngpaste) |

---

### Tmux

| Key | Action |
|-----|--------|
| `M-b` | Prefix |
| `v` | Begin selection (copy mode) |
| `y` | Copy selection |
| `Enter` | Copy selection |
| `M-h/j/k/l` | Navigate panes and nvim |
| `M-b r` | Reload configuration |

---

### skhd

| Key | Action |
|-----|--------|
| `ctrl+1` | Focus Kitty, switch to nvim |
| `ctrl+2` | Focus Kitty, switch to shell |
| `ctrl+3` | Focus Kitty, switch to opencode |
| `ctrl+4` | Focus Brave Browser |

---

### cx (Workspace Manager)

| Command | Action |
|---------|--------|
| `cx` | Create new workspace |
| `cx N` | Create workspace N |
| `cxd` | Detach from workspace |
| `cx1-9` | Switch to workspace 1-9 |
| `cxx1-9` | Kill workspace 1-9 |
| `cxl` | List workspaces |
| `cxf` | Fuzzy find project |
| `cxs` | Fuzzy switch session |
| `cxk` | Fuzzy kill sessions |

---

### cp (Competitive Programming)

| Command | Action |
|---------|--------|
| `cpn <name>` | Scaffold new problem (directory + template + tmux window) |
| `cpr` | Compile & run with sanitizers (debug mode) |
| `cpr -r` | Compile & run in release mode |
| `cpnf` | Fuzzy open an existing problem |
| `cpnl` | List all problems |
| `cpnd` | Fuzzy delete problems |

---

### Shell Aliases

| Alias | Action |
|-------|--------|
| `t` | Attach to tmux or create new session |
| `ta` | `tmux attach` |
| `tl` | `tmux list-sessions` |
| `pdf <file>` | Open PDF in Sioyek (background) |
| `ds` | Interactive offline doc search |

---

## Neovim Plugins

| Plugin | Purpose |
|--------|---------|
| lazy.nvim | Plugin manager |
| catppuccin | Colorscheme (Frappé, transparent) |
| nvim-cmp + LuaSnip | Autocompletion with snippets |
| telescope.nvim | Fuzzy finder (fzf-native, ui-select) |
| nvim-treesitter | Syntax highlighting + folding |
| gitsigns.nvim | Git gutter signs + hunk actions |
| diffview.nvim | Git diff viewer |
| harpoon2 | Quick file access |
| oil.nvim | File explorer (replaces netrw) |
| nvim-autopairs | Bracket matching |
| mason.nvim | LSP server installer |
| nvim-lspconfig | LSP configuration |
| image.nvim | Inline image rendering (kitty protocol) |
| render-markdown.nvim | Rich markdown rendering |
| nvim-web-devicons | File type icons |
| vim-tmux-navigator | Seamless tmux/nvim navigation |

### LSP Servers (auto-installed via Mason)

`html` · `cssls` · `tailwindcss` · `eslint` · `ts_ls` · `lua_ls` · `pyright` · `bashls` · `gopls` · `rust_analyzer` · `clangd` · `jsonls` · `yamlls` · `dockerls` · `marksman` · `sqlls`

---

## Tmux Plugins

| Plugin | Purpose |
|--------|---------|
| tpm | Plugin manager |
| tmux-sensible | Sensible defaults |
| tmux-resurrect | Session save/restore |
| tmux-continuum | Auto-save sessions (every 5 min) |
| vim-tmux-navigator | Seamless pane/nvim navigation |
| tmux-tokyo-night | Tokyo Night theme |

---

## Git Hooks

A global `prepare-commit-msg` hook that generates **Conventional Commit** messages using the Gemini API. See [git/hooks/README.md](git/hooks/README.md) for setup instructions.

---

## Directory Structure

```
~/.config/
├── README.md
├── install.sh
├── starship.toml          # Starship prompt config
│
├── nvim/                   # Neovim configuration
│   ├── init.lua
│   └── lua/
│       ├── config/lazy.lua
│       ├── keymaps.lua
│       ├── lsp/            # Native LSP setup (Neovim 0.11+)
│       └── plugins/        # Lazy.nvim plugin specs
│
├── kitty/                  # Kitty terminal
│   ├── kitty.conf
│   └── kitty-themes/       # Theme collection (Tokyo Night Storm active)
│
├── tmux/
│   └── tmux.conf
│
├── yabai/
│   └── yabairc
│
├── skhd/
│   └── skhdrc
│
├── cx/
│   └── cx.sh               # Workspace manager
│
├── ds/
│   └── ds.sh               # Offline doc search (dedoc + fzf)
│
├── cp/                     # Competitive programming toolkit
│   ├── cpr.sh              # Compiler & judge
│   ├── cpn.sh              # New problem scaffolder
│   ├── cpnf.sh             # Fuzzy open
│   ├── cpnd.sh             # Fuzzy delete
│   ├── cpnl.sh             # List problems
│   ├── template.cpp        # Problem template
│   └── include/            # stdc++.h precompiled header
│
├── opencode/               # OpenCode AI config + agents
│   ├── opencode.json
│   └── agents/
│
├── git/
│   └── hooks/              # Global git hooks
│       └── prepare-commit-msg
│
├── sioyek/                 # PDF reader
│   ├── keys_user.config
│   └── prefs_user.config
│
└── zed/                    # Zed editor
    └── settings.json
```

---

## Troubleshooting

**tmux navigator not working**
Ensure vim-tmux-navigator plugin is loaded in both nvim and tmux.

**cx commands not found**
Source the file in `.zshrc`: `source ~/.config/cx/cx.sh`

**yabai not tiling / animations still present**
Verify SIP status: `csrutil status` — must be fully disabled.

**LSP not attaching**
Run `:checkhealth lsp` in Neovim. Ensure Mason has installed the servers (`:Mason`).

**Images not rendering in Neovim**
Requires Kitty terminal with graphics protocol. Ensure `image.nvim` is loaded and `tmux` has `allow-passthrough on`.

**AI commit hook not working**
Ensure `GEMINI_API_KEY` is exported in your `~/.zshrc` and `jq` + `curl` are installed. Run `git config --global core.hooksPath` to verify it points to `~/.config/git/hooks`.
