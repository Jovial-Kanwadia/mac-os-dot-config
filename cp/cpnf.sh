#!/usr/bin/env bash
BASE_DIR="$HOME/programming/cp"
SELECTED=$(ls -1 "$BASE_DIR" | fzf --prompt="🚀 Open Problem> " --height=40% --reverse)

if [[ -n "$SELECTED" ]]; then
    cd "$BASE_DIR/$SELECTED"
    # Rename tmux window if inside tmux
    [ -n "$TMUX" ] && tmux rename-window "$SELECTED"
    nvim sol.cpp
fi
