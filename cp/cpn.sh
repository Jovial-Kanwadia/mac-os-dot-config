#!/usr/bin/env bash

BASE_DIR="$HOME/Programming/CP"
PROBLEM_NAME=$1

if [[ -z "$PROBLEM_NAME" ]]; then
    echo "Usage: cpn <problem_name>"
    exit 1
fi

TARGET_DIR="$BASE_DIR/$PROBLEM_NAME"
TEMPLATE="$HOME/.config/cp/template.cpp"

mkdir -p "$TARGET_DIR"
touch "$TARGET_DIR/in.txt"
touch "$TARGET_DIR/ans.txt"

if [[ -f "$TEMPLATE" ]]; then
    cp "$TEMPLATE" "$TARGET_DIR/sol.cpp"
else
    echo -e "#include <iostream>\nusing namespace std;\n\nint main() {\n    return 0;\n}" > "$TARGET_DIR/sol.cpp"
fi

cd "$TARGET_DIR"

echo -e "\033[0;32m Created $PROBLEM_NAME. Moving to workspace...\033[0m"

if [ -n "$TMUX" ]; then
    tmux new-window -n "$PROBLEM_NAME" -c "$TARGET_DIR" "nvim sol.cpp"
else
    cd "$TARGET_DIR" && nvim sol.cpp
fi
