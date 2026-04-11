#!/usr/bin/env bash
BASE_DIR="$HOME/programming/cp"
echo -e "\033[0;34m📂 Existing Problems:\033[0m"
ls -1 "$BASE_DIR" | sed 's/^/  • /'
