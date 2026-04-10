#!/usr/bin/env bash
set -e

echo "Welcome to the macOS Terminal Setup"
echo "========================================="

# 1. Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew is already installed."
fi

# 2. Install Dependencies
echo "Installing CLI tools and Casks..."
brew install koekeishiya/formulae/yabai
brew install skhd
brew install tmux
brew install neovim
brew install starship
brew install fzf
brew install coreutils
brew install bc
brew install --cask kitty
brew install --cask brave-browser

# 3. Setup Yabai Passwordless Sudo (For the Scripting Addition)
echo "Configuring Yabai Scripting Addition bypass..."
YABAI_PATH=$(brew --prefix)/bin/yabai
SUDOERS_FILE="/private/etc/sudoers.d/yabai"

if [ ! -f "$SUDOERS_FILE" ]; then
    echo "$(whoami) ALL=(root) NOPASSWD: ${YABAI_PATH} --load-sa" | sudo tee "$SUDOERS_FILE" > /dev/null
    echo "Yabai sudoers configured."
else
    echo "Yabai sudoers already configured."
fi

# 4. Tmux Plugins
echo "Setting up Tmux plugins..."
mkdir -p ~/.config/tmux/plugins
if [ ! -d "$HOME/.config/tmux/plugins/tmux-continuum" ]; then
    git clone https://github.com/tmux-plugins/tmux-continuum ~/.config/tmux/plugins/tmux-continuum
fi
if [ ! -d "$HOME/.config/tmux/plugins/tmux-resurrect" ]; then
    git clone https://github.com/tmux-plugins/tmux-resurrect ~/.config/tmux/plugins/tmux-resurrect
fi

# 5. ZSH Integration
echo "Linking to ~/.zshrc..."
grep -q "source ~/.config/cx/cx.sh" ~/.zshrc || echo "source ~/.config/cx/cx.sh" >> ~/.zshrc
grep -q "starship init zsh" ~/.zshrc || echo 'eval "$(starship init zsh)"' >> ~/.zshrc

grep -q "alias cpr=" ~/.zshrc || echo "alias cpr='~/.config/cp/cpr.sh'" >> ~/.zshrc
grep -q "alias cpn=" ~/.zshrc || echo "alias cpn='source ~/.config/cp/cpn.sh'" >> ~/.zshrc

# 6. Competitive Programming Header Setup
echo "Setting up CP Header Environment..."
HEADER_DIR="$HOME/.config/cp/include/bits"
mkdir -p "$HEADER_DIR"

if [ ! -f "$HEADER_DIR/stdc++.h" ]; then
    echo "📥 Downloading stdc++.h..."
    curl -s https://raw.githubusercontent.com/gcc-mirror/gcc/master/libstdc%2B%2B-v3/include/precompiled/stdc%2B%2B.h -o "$HEADER_DIR/stdc++.h"
fi

echo "⚡ Precompiling stdc++.h (this may take a few seconds)..."
# Using -x c++-header to silence the deprecated warning
clang++ -std=c++20 -x c++-header "$HEADER_DIR/stdc++.h"

# 6. Start the Engines
echo "Starting background services..."
yabai --start-service || yabai --restart-service
skhd --start-service || skhd --restart-service

echo "========================================="
echo "Setup Complete!"
echo "1. Run 'source ~/.zshrc' to refresh your shell."
echo "2. Ensure you have run Phase 1 (SIP & NVRAM) from README.md."

