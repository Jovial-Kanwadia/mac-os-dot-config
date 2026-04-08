# Dotfiles

A terminal-first macOS workflow using tmux, Neovim, and a custom workspace manager. 
Peak Feature - Uses yabai and skhd to get rid of ugly macOS animations.

## Prerequisites

SIP must be disabled for yabai to work. Follow the standard yabai installation guide.

## Installation

```bash
git clone https://github.com/Jovial-Kanwadia/mac-os-dot-config.git ~/.config
cd ~/.config
./install.sh
```

Add to `~/.zshrc`:

```bash
source ~/.config/cx/cx.sh
```

## Architecture

```
                    ┌─────────────────────────────────────┐
                    │           skhd (Global Hotkeys)     │
                    │                                     │
                    │  Ctrl+1 → Kitty + Window 1          │
                    │  Ctrl+2 → Kitty + Window 2          │
                    │  Ctrl+3 → Kitty + Window 3          │
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
```

## Keybindings

### Neovim

#### General

| Key | Action |
|-----|--------|
| `j`, `k` | Navigate wrapped lines |
| `<C-d>`, `<C-u>` | Scroll down/up (cursor centered) |
| `n`, `N` | Next/previous search match (cursor centered) |
| `<CR>` | Insert newline below |
| `<leader>e` | Toggle Neotree |
| `-` | Open Oil file explorer |
| `v` + `y` | Yank to system clipboard |
| `<leader>fc` | Show all commands |

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

#### LSP

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

### cx

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

## Plugins

| Plugin | Purpose |
|--------|---------|
| nvim-lspconfig | LSP configuration |
| nvim-cmp | Autocompletion |
| telescope.nvim | Fuzzy finder |
| nvim-treesitter | Syntax highlighting |
| gitsigns.nvim | Git gutter signs |
| diffview.nvim | Git diff viewer |
| harpoon | Quick file access |
| oil.nvim | File explorer |
| catppuccin | Colorscheme |
| nvim-autopairs | Bracket matching |

---

## Troubleshooting

**tmux navigator not working**
Ensure vim-tmux-navigator plugin is loaded in nvim.

**cx commands not found**
Source the file in `.zshrc`: `source ~/.config/cx/cx.sh`

**yabai not tiling**
Verify SIP status: `csrutil status`
