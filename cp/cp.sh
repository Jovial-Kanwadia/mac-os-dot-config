#!/usr/bin/env zsh
# cp.sh — Competitive Programming Toolkit
# Source this in your ~/.zshrc: source ~/.config/cp/cp.sh

# ─── Unalias any collisions before defining functions ─────────────────
# (cpr may be defined as an alias from a previous install)
(( $+aliases[cpr]  )) && unalias cpr
(( $+aliases[cp]  )) && unalias cp
(( $+aliases[cpf] )) && unalias cpf
(( $+aliases[cpl] )) && unalias cpl
(( $+aliases[cpd] )) && unalias cpd

# ─── Config ──────────────────────────────────────────────────────────
CP_BASE_DIR="$HOME/Programming/CP"
CP_TEMPLATE="$HOME/.config/cp/template.cpp"
CP_HEADER_PATH="$HOME/.config/cp/include"

# ─── Colors ──────────────────────────────────────────────────────────
_cp_blue='\033[0;34m'
_cp_green='\033[0;32m'
_cp_red='\033[0;31m'
_cp_nc='\033[0m'

# ─── cp - new problem ───────────────────────────────────────────────
cp() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "Usage: cpn <problem_name>"
    return 1
  fi

  local target="$CP_BASE_DIR/$name"
  mkdir -p "$target"
  touch "$target/in.txt" "$target/ans.txt"

  if [[ -f "$CP_TEMPLATE" ]]; then
    # Use /bin/cp explicitly to avoid any function/alias collision
    /bin/cp "$CP_TEMPLATE" "$target/sol.cpp"
  else
    printf '#include <iostream>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n' > "$target/sol.cpp"
  fi

  echo -e "${_cp_green}✓ Created $name${_cp_nc}"

  if [[ -n "$TMUX" ]]; then
    tmux new-window -n "$name" -c "$target" "nvim sol.cpp"
  else
    cd "$target" && nvim sol.cpp
  fi
}

# ─── cpr - compile & run ─────────────────────────────────────────────
cpr() {
  local SOURCE="sol.cpp"
  local BINARY="sol.out"
  local INPUT="in.txt"
  local OUTPUT="out.txt"
  local ANS="ans.txt"
  local MODE CFLAGS

  if [[ "$1" == "-r" ]]; then
    CFLAGS="-std=c++20 -O2 -I$CP_HEADER_PATH"
    MODE="RELEASE"
  else
    CFLAGS="-std=c++20 -Wall -Wextra -Wshadow -fsanitize=address,undefined -g -I$CP_HEADER_PATH"
    MODE="DEBUG"
  fi

  echo -e "${_cp_blue}● Compiling in $MODE mode...${_cp_nc}"
  if ! clang++ $=CFLAGS "$SOURCE" -o "$BINARY"; then
    echo -e "${_cp_red}✗ Compilation Failed${_cp_nc}"
    return 1
  fi

  echo -e "${_cp_blue}┌── Validating Execution ─────────────────────────────────┐${_cp_nc}"

  if gtimeout 2s /usr/bin/time -l ./"$BINARY" < "$INPUT" > "$OUTPUT" 2> .stats; then
    local TIME MEM_BYTES MEM_MB VERDICT
    TIME=$(grep "real" .stats | awk '{print $1}')
    MEM_BYTES=$(grep "maximum resident set size" .stats | awk '{print $1}')
    MEM_MB=$(echo "scale=2; $MEM_BYTES / 1024 / 1024" | bc)

    VERDICT="${_cp_green}PASS${_cp_nc}"
    if [[ -f "$ANS" ]] && ! diff -w "$OUTPUT" "$ANS" > /dev/null; then
      VERDICT="${_cp_red}FAIL${_cp_nc}"
    fi

    echo -e "${_cp_blue}│${_cp_nc} Verdict: $VERDICT"
    echo -e "${_cp_blue}│${_cp_nc} Time:    ${TIME}s"
    echo -e "${_cp_blue}│${_cp_nc} Memory:  ${MEM_MB}MB"
    echo -e "${_cp_blue}└─────────────────────────────────────────────────────────┘${_cp_nc}"
    echo -e "\n${_cp_blue}Output:${_cp_nc}"
    cat "$OUTPUT"

    if [[ "$VERDICT" == *FAIL* ]]; then
      echo -e "\n${_cp_red}Diff (Yours vs. Expected):${_cp_nc}"
      diff -w -y --suppress-common-lines "$OUTPUT" "$ANS"
    else
      cat "$OUTPUT" | pbcopy
    fi
  else
    local exit_code=$?
    echo -e "${_cp_blue}│${_cp_nc} Verdict: ${_cp_red}ERROR${_cp_nc}"
    echo -e "${_cp_blue}└─────────────────────────────────────────────────────────┘${_cp_nc}"
    if [[ $exit_code -eq 124 ]]; then
      echo -e "${_cp_red}❌ TLE (Time Limit Exceeded > 2s)${_cp_nc}"
    else
      echo -e "${_cp_red}❌ RUNTIME ERROR (Check Sanitizers)${_cp_nc}"
      grep "AddressSanitizer" .stats 2>/dev/null
    fi
  fi

  rm -f .stats
}

# ─── cpf - fuzzy open problem ───────────────────────────────────────
cpf() {
  local selected
  selected=$(ls -1 "$CP_BASE_DIR" 2>/dev/null | fzf --prompt="🚀 Open Problem> " --height=40% --reverse)
  [[ -z "$selected" ]] && return 0

  cd "$CP_BASE_DIR/$selected"
  [[ -n "$TMUX" ]] && tmux rename-window "$selected"
  nvim sol.cpp
}

# ─── cpl - list problems ────────────────────────────────────────────
cpl() {
  echo -e "${_cp_blue}📂 Problems in $CP_BASE_DIR:${_cp_nc}"
  ls -1 "$CP_BASE_DIR" 2>/dev/null | sed 's/^/  • /' || echo "  (none)"
}

# ─── cpd - delete problem(s) ────────────────────────────────────────
cpd() {
  local selected
  selected=$(ls -1 "$CP_BASE_DIR" 2>/dev/null | fzf -m \
    --prompt="🗑  Delete (TAB=multi-select)> " --height=40% --reverse)
  [[ -z "$selected" ]] && return 0

  echo -e "${_cp_red}⚠️  Will permanently delete:${_cp_nc}"
  echo "$selected"
  echo -n "Confirm? [y/N] "
  read -r confirm
  [[ ! "$confirm" =~ ^[Yy]$ ]] && echo "Cancelled." && return 0

  local cwd jumped=false
  cwd=$(pwd)

  while IFS= read -r item; do
    local target="$CP_BASE_DIR/$item"
    if [[ "$cwd" == "$target"* ]]; then
      jumped=true
    fi
    rm -rf "$target"
    echo -e "  ${_cp_red}✗ Deleted $item${_cp_nc}"
  done <<< "$selected"

  if [[ "$jumped" == true ]]; then
    cd "$CP_BASE_DIR"
    echo -e "${_cp_blue}ℹ  Jumped back to $CP_BASE_DIR${_cp_nc}"
  fi
}
