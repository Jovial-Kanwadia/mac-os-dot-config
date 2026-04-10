#!/usr/bin/env bash

# 1. Config - Change this to where you keep your problems
BASE_DIR="$HOME/Programming/CP"
PROBLEM_NAME=$1

if [[ -z "$PROBLEM_NAME" ]]; then
    echo "Usage: cpn <problem_name>"
    exit 1
fi

TARGET_DIR="$BASE_DIR/$PROBLEM_NAME"
TEMPLATE="$HOME/.config/cp/template.cpp"

# 2. Setup folder and files
mkdir -p "$TARGET_DIR"
touch "$TARGET_DIR/in.txt"
touch "$TARGET_DIR/ans.txt"

# 3. Use template or create empty sol.cpp
if [[ -f "$TEMPLATE" ]]; then
    cp "$TEMPLATE" "$TARGET_DIR/sol.cpp"
else
    echo -e "#include <iostream>\nusing namespace std;\n\nint main() {\n    return 0;\n}" > "$TARGET_DIR/sol.cpp"
fi

cd "$TARGET_DIR"

# 4. Teleport
echo -e "\033[0;32m🚀 Created $PROBLEM_NAME. Moving to workspace...\033[0m"

# If inside tmux, create a new window for the problem
if [ -n "$TMUX" ]; then
    tmux new-window -n "$PROBLEM_NAME" -c "$TARGET_DIR" "nvim sol.cpp"
else
    cd "$TARGET_DIR" && nvim sol.cpp
fi
