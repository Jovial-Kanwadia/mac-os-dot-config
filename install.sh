#!/usr/bin/env bash
set -e

# ═══════════════════════════════════════════════════════════════════════
#  macOS Development Environment — Full Setup Script
#  Run once on a fresh Mac to replicate the entire workflow.
# ═══════════════════════════════════════════════════════════════════════

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           macOS Terminal Environment Setup                    ║"
echo "║  ⚠  This script is designed for zsh (macOS default shell)     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# ─── 0. Shell Check ───────────────────────────────────────────────────
if [ ! -f "$HOME/.zshrc" ] && ! command -v zsh &>/dev/null; then
	echo "This setup requires zsh (the default macOS shell)."
	echo "   It will NOT work with bash, fish, or other shells."
	exit 1
fi

# ─── 1. Xcode Command Line Tools ──────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
	echo "Installing Xcode Command Line Tools..."
	xcode-select --install
	echo "Please complete the Xcode CLT installation, then re-run this script."
	exit 1
else
	echo "Xcode CLT already installed."
fi

# ─── 2. Homebrew ──────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/opt/homebrew/bin/brew shellenv)"
else
	echo "Homebrew already installed."
fi

# ─── 3. Homebrew Formulae ─────────────────────────────────────────────
echo ""
echo "Installing CLI tools..."

FORMULAE=(
	# Core tools
	neovim
	tmux
	starship
	fzf
	ripgrep
	fd
	bat
	lazygit
	yazi
	zoxide
	fastfetch
	tree
	jq
	coreutils
	bc

	# Window management
	koekeishiya/formulae/yabai
	skhd

	# Shell enhancements
	zsh-autosuggestions
	zsh-syntax-highlighting

	# Languages & compilers
	go
	node
	lua
	luajit
	luarocks
	llvm

	# Image & media (for image.nvim, pngpaste, etc.)
	imagemagick
	pngpaste
	chafa
	libarchive

	# AI tools
	opencode

	# Build tools
	cmake
	ninja
	bear

	# Containers & cloud
	docker
	docker-completion
	kubernetes-cli
	helm
	kind
	kubebuilder

	# Other
	ollama
	poppler
)

for formula in "${FORMULAE[@]}"; do
	if brew list --formula "$formula" &>/dev/null; then
		echo "  ✓ $formula"
	else
		echo "  ⬇ Installing $formula..."
		brew install "$formula" || echo "  ⚠ Failed to install $formula (non-fatal)"
	fi
done

# ─── 4. Homebrew Casks ────────────────────────────────────────────────
echo ""
echo "Installing GUI applications..."

CASKS=(
	kitty
	brave-browser
	sioyek
)

for cask in "${CASKS[@]}"; do
	if brew list --cask "$cask" &>/dev/null; then
		echo "  ✓ $cask"
	else
		echo "  ⬇ Installing $cask..."
		brew install --cask "$cask" || echo "  ⚠ Failed to install $cask (non-fatal)"
	fi
done

# ─── 5. Fonts ─────────────────────────────────────────────────────────
echo ""
echo "Installing Nerd Fonts..."

FONTS=(
	font-jetbrains-mono-nerd-font
	font-symbols-only-nerd-font
	font-fantasque-sans-mono-nerd-font
)

for font in "${FONTS[@]}"; do
	if brew list --cask "$font" &>/dev/null; then
		echo "  ✓ $font"
	else
		echo "  ⬇ Installing $font..."
		brew install --cask "$font" || echo "  ⚠ Failed to install $font (non-fatal)"
	fi
done

# ─── 6. Oh My Zsh ────────────────────────────────────────────────────
echo ""
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo "Installing Oh My Zsh..."
	RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
	echo "Oh My Zsh already installed."
fi

# ─── 7. Rust Toolchain ───────────────────────────────────────────────
echo ""
if ! command -v rustup &>/dev/null; then
	echo "Installing Rust toolchain..."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source "$HOME/.cargo/env"
else
	echo "Rust toolchain already installed."
fi

# Install dedoc via cargo (offline documentation browser)
if ! command -v dedoc &>/dev/null; then
	echo "  ⬇ Installing dedoc (offline docs)..."
	cargo install dedoc || echo "  ⚠ Failed to install dedoc (non-fatal)"
else
	echo "  ✓ dedoc"
fi

# ─── 8. Bun Runtime ──────────────────────────────────────────────────
echo ""
if [ ! -d "$HOME/.bun" ]; then
	echo "Installing Bun..."
	curl -fsSL https://bun.sh/install | bash
else
	echo "Bun already installed."
fi

# ─── 9. Yabai Passwordless Sudo ──────────────────────────────────────
echo ""
echo "Configuring Yabai scripting addition..."
YABAI_PATH=$(brew --prefix)/bin/yabai
SUDOERS_FILE="/private/etc/sudoers.d/yabai"

if [ ! -f "$SUDOERS_FILE" ]; then
	echo "$(whoami) ALL=(root) NOPASSWD: ${YABAI_PATH} --load-sa" | sudo tee "$SUDOERS_FILE" >/dev/null
	echo "  ✓ Yabai sudoers configured."
else
	echo "  ✓ Yabai sudoers already configured."
fi

# ─── 10. Tmux Plugin Manager (TPM) ───────────────────────────────────
echo ""
echo "Setting up tmux plugins..."
mkdir -p ~/.config/tmux/plugins

if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
	echo "⬇ Installing TPM..."
	git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi

# Install all tmux plugins via TPM
echo "⬇ Installing tmux plugins..."
~/.config/tmux/plugins/tpm/bin/install_plugins 2>/dev/null || true

# ─── 11. Neovim Plugin Bootstrap ─────────────────────────────────────
echo ""
echo "Bootstrapping Neovim plugins..."
# Lazy.nvim auto-installs on first launch; just trigger it headlessly
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
echo "  ✓ Neovim plugins synced."

# ─── 12. Competitive Programming Setup ───────────────────────────────
echo ""
echo "Setting up competitive programming environment..."

# Create CP directory
mkdir -p "$HOME/Programming/CP"

# Download and precompile stdc++.h
HEADER_DIR="$HOME/.config/cp/include/bits"
mkdir -p "$HEADER_DIR"

mkdir -p ~/Library/Preferences/clangd

cat >~/Library/Preferences/clangd/config.yaml <<'EOF'
CompileFlags:
  Add:
    - "-std=c++17"
    - "-I$HOME/.config/cp/include"
EOF

if [ ! -f "$HEADER_DIR/stdc++.h" ]; then
	echo "Downloading stdc++.h..."
	curl -s https://raw.githubusercontent.com/gcc-mirror/gcc/master/libstdc%2B%2B-v3/include/precompiled/stdc%2B%2B.h -o "$HEADER_DIR/stdc++.h"
fi

echo "Precompiling stdc++.h (this may take a few seconds)..."
clang++ -std=c++20 -x c++-header "$HEADER_DIR/stdc++.h" 2>/dev/null || echo "  ⚠ Precompilation failed (non-fatal)"

# Make CP scripts executable
chmod +x ~/.config/cp/*.sh 2>/dev/null || true

# ─── 13. Git Hooks Setup ─────────────────────────────────────────────
echo ""
echo "Configuring global git hooks..."

# Set global hooks path
git config --global core.hooksPath ~/.config/git/hooks

# Make hook executable
chmod +x ~/.config/git/hooks/prepare-commit-msg

# Add convenient alias
git config --global alias.ac '!git add -A && git commit'

echo "  ✓ Global hooks → ~/.config/git/hooks"
echo "  ✓ git ac alias configured"

# ─── 14. ds.sh (Doc Search) Setup ────────────────────────────────────
echo ""
echo "Setting up doc search..."
chmod +x ~/.config/ds/ds.sh 2>/dev/null || true
echo "  ✓ ds.sh ready at ~/.config/ds/ds.sh"

# ─── 15. ZSH Configuration ───────────────────────────────────────────
echo ""
echo "Configuring ~/.zshrc..."

# Helper: append a line to .zshrc if not already present
add_to_zshrc() {
	local pattern="$1"
	local line="$2"
	grep -qF "$pattern" ~/.zshrc 2>/dev/null || echo "$line" >>~/.zshrc
}

# Cargo/Rust
add_to_zshrc '.cargo/env' '. "$HOME/.cargo/env"'

# Go
add_to_zshrc 'go env GOPATH' 'export PATH="$(go env GOPATH)/bin:$PATH"'

# Local bin
add_to_zshrc '.local/bin' 'export PATH="$HOME/.local/bin:$PATH"'

# Bun
add_to_zshrc '.bun/_bun' '[ -s "/Users/$(whoami)/.bun/_bun" ] && source "/Users/$(whoami)/.bun/_bun"'
add_to_zshrc 'BUN_INSTALL' 'export BUN_INSTALL="$HOME/.bun"'
add_to_zshrc 'BUN_INSTALL/bin' 'export PATH="$BUN_INSTALL/bin:$PATH"'

# Shell plugins
add_to_zshrc 'zsh-autosuggestions.zsh' 'source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh'
add_to_zshrc 'zsh-syntax-highlighting.zsh' 'source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

# Starship prompt
add_to_zshrc 'starship init zsh' 'eval "$(starship init zsh)"'

# fzf integration
add_to_zshrc 'fzf --zsh' 'source <(fzf --zsh)'

# cx workspace manager
add_to_zshrc 'source ~/.config/cx/cx.sh' 'source ~/.config/cx/cx.sh'

# CP toolkit (single source, all commands: cpn cpr cpr -r cpnf cpnl cpnd)
add_to_zshrc 'source ~/.config/cp/cp.sh' 'source ~/.config/cp/cp.sh'

# ds (doc search)
add_to_zshrc "alias ds=" "alias ds='source ~/.config/ds/ds.sh'"

# Tmux aliases
add_to_zshrc "alias ta=" "alias ta='tmux attach'"
add_to_zshrc "alias tl=" "alias tl='tmux list-sessions 2> /dev/null'"

# LLVM and libarchive
add_to_zshrc '/opt/homebrew/opt/llvm/bin' 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"'
add_to_zshrc 'LDFLAGS' 'export LDFLAGS="-L/opt/homebrew/opt/llvm/lib -L/opt/homebrew/opt/libarchive/lib"'
add_to_zshrc 'CPPFLAGS' 'export CPPFLAGS="-I/opt/homebrew/opt/llvm/include -I/opt/homebrew/opt/libarchive/include"'

# OpenCode environment
add_to_zshrc 'OPENCODE_DISABLE_CLAUDE_CODE=' 'export OPENCODE_DISABLE_CLAUDE_CODE=1'
add_to_zshrc 'OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=' 'export OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=1'
add_to_zshrc 'OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=' 'export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1'
add_to_zshrc 'OPENCODE_AUTO_SHARE=' 'export OPENCODE_AUTO_SHARE=0'
add_to_zshrc 'OPENCODE_DISABLE_AUTOUPDATE=' 'export OPENCODE_DISABLE_AUTOUPDATE=1'
add_to_zshrc 'OPENCODE_ENABLE_EXA=' 'export OPENCODE_ENABLE_EXA=1'

# Shell functions
if ! grep -q '^t()' ~/.zshrc 2>/dev/null; then
	cat >>~/.zshrc <<'FUNC'

t() {
  if [ $# -eq 0 ]; then
    tmux attach || tmux new-session
  else
    tmux "$@"
  fi
}

pdf() {
    sioyek "$@" > /dev/null 2>&1 &
    disown
}
FUNC
fi

echo "  ✓ ~/.zshrc configured."

# ─── 16. API Keys Reminder ───────────────────────────────────────────
echo ""
echo "API Keys — you must set these manually:"
echo "  • GEMINI_API_KEY    → export in ~/.zshrc or put in ~/.config/gemini_api_key"
echo "  • OPENROUTER_API_KEY → export in ~/.zshrc"
echo "  • EXA_API_KEY       → export in ~/.zshrc (for OpenCode Exa MCP)"

# ─── 17. Start Services ──────────────────────────────────────────────
echo ""
echo "Starting background services..."
yabai --start-service 2>/dev/null || yabai --restart-service 2>/dev/null || true
skhd --start-service 2>/dev/null || skhd --restart-service 2>/dev/null || true
echo "  ✓ yabai and skhd services started."

# ═══════════════════════════════════════════════════════════════════════
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    Setup Complete! 🎉                         ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  1. Run 'source ~/.zshrc' to refresh your shell               ║"
echo "║  2. Set your API keys (GEMINI, OPENROUTER, EXA)               ║"
echo "║  3. Open Kitty → run 't' to start tmux                        ║"
echo "║  4. In tmux, press prefix+I to install tmux plugins           ║"
echo "║  5. Open nvim → ':Lazy sync' and ':Mason' verify LSP servers  ║"
echo "║  6. Ensure SIP is disabled for yabai (csrutil status)         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
