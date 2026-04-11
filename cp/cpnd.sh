#!/usr/bin/env bash

BASE_DIR="$HOME/Programming/CP"
SELECTED=$(ls -1 "$BASE_DIR" | fzf -m --prompt="🗑 Delete Problem (TAB to multi-select)> " --height=40% --reverse)

if [[ -n "$SELECTED" ]]; then
    echo -e "\033[0;31m⚠️  Are you sure you want to delete:\033[0m"
    echo "$SELECTED"
    echo -n "Confirm? [y/N] "
    read confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        CWD=$(pwd)
        SHOULD_JUMP_BACK=false

        echo "$SELECTED" | while read -r item; do
            TARGET="$BASE_DIR/$item"
            
            # Check if we are currently inside the folder we are deleting
            if [[ "$CWD" == "$TARGET"* ]]; then
                SHOULD_JUMP_BACK=true
            fi
            
            rm -rf "$TARGET"
            echo "Deleted $item"
        done

        # If we deleted our own house, move back to the base directory
        if [ "$SHOULD_JUMP_BACK" = true ]; then
            cd "$BASE_DIR"
            echo -e "\033[0;34mℹ️  Current directory was deleted. Jumped back to $BASE_DIR\033[0m"
        fi
    else
        echo "Cancelled."
    fi
fi
