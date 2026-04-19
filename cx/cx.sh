#!/usr/bin/env zsh

# Get the project name from current directory
_cx_project_name() {
  if [[ -n "$TMUX" ]]; then
    tmux display-message -p "#{session_name}" | sed 's/-c[0-9]*$//'
  else
    basename "$(pwd)"
  fi
}

# Attach or switch to a session
_cx_attach() {
  local session="$1"
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}

# ─── cx - create workspace ───────────────────────────────
cx() {
  local dir="$(pwd)"
  local project="$(basename "$dir")"

  # Handle help flag
  if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    cat << 'EOF'
cx - Workspace Manager

Usage: cx [N]
  cx       Create new workspace
  cx N     Create workspace N (e.g., cx 3 creates project-c3)
  cxl      List workspaces
  cxf      Fuzzy find project
  cxs      Fuzzy switch sessions
  cxk      Fuzzy kill sessions
  cx1-9    Switch to workspace 1-9
  cxx1-9   Kill workspace 1-9
EOF
    return 0
  fi

  # Check tmux
  if ! command -v tmux &>/dev/null; then
    echo "Error: tmux not found"
    return 1
  fi

  # Find next available workspace or use specified number
  local target
  if [[ -n "${1:-}" ]] && [[ "$1" =~ ^[0-9]+$ ]]; then
    target="${project}-c${1}"
    if tmux has-session -t "$target" 2>/dev/null; then
      echo "Session $target exists, attaching..."
      _cx_attach "$target"
      return 0
    fi
  else
    local n=1
    while tmux has-session -t "${project}-c${n}" 2>/dev/null; do
      ((n++))
    done
    target="${project}-c${n}"
  fi

  echo "Creating workspace: $target"

  # Create session
  tmux new-session -d -s "$target" -c "$dir"

  # Window 1: nvim
  tmux rename-window -t "$target:1" "nvim"
  tmux send-keys -t "$target:1" "nvim ." Enter

  # Window 2: shell
  tmux new-window -t "$target" -n "shell" -c "$dir"

  # Window 3: opencode
  tmux new-window -t "$target" -n "opencode" -c "$dir"
  tmux send-keys -t "$target:3" "opencode" Enter

  # Select nvim window
  tmux select-window -t "$target:1"

  _cx_attach "$target"
}

# ─── cx1-9 - switch workspace ───────────────────────────
cx1() { _cx_switch 1; }
cx2() { _cx_switch 2; }
cx3() { _cx_switch 3; }
cx4() { _cx_switch 4; }
cx5() { _cx_switch 5; }
cx6() { _cx_switch 6; }
cx7() { _cx_switch 7; }
cx8() { _cx_switch 8; }
cx9() { _cx_switch 9; }

_cx_switch() {
  local n="$1"
  local project="$(_cx_project_name)"
  local target="${project}-c${n}"

  if tmux has-session -t "$target" 2>/dev/null; then
    _cx_attach "$target"
  else
    echo "No workspace: $target"
    echo "Available:"
    tmux list-sessions -F "#{session_name}" 2>/dev/null | grep "^${project}-c" | sed 's/^/  /'
  fi
}

# ─── cxx1-9 - kill workspace ───────────────────────────
cxx1() { _cx_kill 1; }
cxx2() { _cx_kill 2; }
cxx3() { _cx_kill 3; }
cxx4() { _cx_kill 4; }
cxx5() { _cx_kill 5; }
cxx6() { _cx_kill 6; }
cxx7() { _cx_kill 7; }
cxx8() { _cx_kill 8; }
cxx9() { _cx_kill 9; }

_cx_kill() {
  local n="$1"
  local project="$(_cx_project_name)"
  local target="${project}-c${n}"

  if ! tmux has-session -t "$target" 2>/dev/null; then
    echo "No workspace: $target"
    return 1
  fi

  # Prevent killing current session
  if [[ -n "$TMUX" ]]; then
    local current
    current="$(tmux display-message -p '#{session_name}')"
    if [[ "$target" == "$current" ]]; then
      echo "Cannot kill current session. Detatch first."
      return 1
    fi
  fi

  echo -n "Kill \"$target\"? [y/N] "
  local confirm
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    tmux kill-session -t "$target"
    echo "Killed: $target"
  else
    echo "Cancelled."
  fi
}

# ─── cxl - list workspaces ─────────────────────────────
cxl() {
  local project="$(_cx_project_name)"
  echo ""
  echo "Project: $project"
  echo ""

  local sessions
  sessions=$(tmux list-sessions -F "#{session_name}|#{?session_attached,attached,detached}" 2>/dev/null | grep "^${project}-c")

  if [[ -z "$sessions" ]]; then
    echo "  No workspaces found"
  else
    local current=""
    if [[ -n "$TMUX" ]]; then
      current="$(tmux display-message -p '#{session_name}')"
    fi

    echo "$sessions" | while IFS='|' read -r name state; do
      if [[ "$name" == "$current" ]]; then
        echo -e "  \033[1;32m● $name\033[0m (you are here)"
      else
        echo "  ○ $name"
      fi
    done
  fi
  echo ""
}

# ─── cxf - fuzzy find project ─────────────────────────
cxf() {
  if ! command -v fzf &>/dev/null; then
    echo "Error: fzf not installed (brew install fzf)"
    return 1
  fi

  local search_dirs=(
    "$HOME/programming"
    "$HOME/.config"
  )

  # Only existing directories
  local valid_dirs=()
  for dir in "${search_dirs[@]}"; do
    [[ -d "$dir" ]] && valid_dirs+=("$dir")
  done

  if [[ ${#valid_dirs[@]} -eq 0 ]]; then
    echo "Error: No search directories exist"
    return 1
  fi

  local selected
  selected=$(find "${valid_dirs[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | fzf --prompt="Open Project> " --height=40% --reverse)

  if [[ -z "$selected" ]]; then
    return 0
  fi

  cd "$selected"
  local project="$(basename "$selected")"

  # Check for existing sessions
  local existing
  existing=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep "^${project}-c")

  if [[ -z "$existing" ]]; then
    cx
  else
    local choice
    choice=$(printf "[+] Create New\n%s" "$existing" | fzf --prompt="Sessions for $project> " --height=40% --reverse)

    if [[ "$choice" == "[+] Create New" ]]; then
      cx
    elif [[ -n "$choice" ]]; then
      _cx_attach "$choice"
    fi
  fi
}

# ─── cxs - fuzzy switch ────────────────────────────────
cxs() {
  if ! command -v fzf &>/dev/null; then
    echo "Error: fzf not installed (brew install fzf)"
    return 1
  fi

  local session
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --prompt="Switch to> " --height=40% --reverse)

  if [[ -n "$session" ]]; then
    _cx_attach "$session"
  fi
}

# ─── cxk - fuzzy kill (permanent — purges from resurrect saves) ────────
cxk() {
  if ! command -v fzf &>/dev/null; then
    echo "Error: fzf not installed (brew install fzf)"
    return 1
  fi

  local current=""
  if [[ -n "$TMUX" ]]; then
    current="$(tmux display-message -p '#{session_name}')"
  fi

  local sessions
  sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf -m --prompt="Kill (TAB=select)> " --height=40% --reverse)

  [[ -z "$sessions" ]] && return 0

  # Resurrect save directory (default location)
  local resurrect_dir="$HOME/.local/share/tmux/resurrect"

  echo "$sessions" | while read -r session; do
    if [[ "$session" == "$current" ]]; then
      echo "Skipping (current): $session"
      continue
    fi

    # 1. Kill the live session
    tmux kill-session -t "$session" 2>/dev/null
    echo "Killed: $session"

    # 2. Scrub the session from every resurrect save file
    #    Resurrect lines begin with: pane|<session>| or window|<session>|
    if [[ -d "$resurrect_dir" ]]; then
      local f
      for f in "$resurrect_dir"/*.txt(N); do
        # Remove any line that belongs to this session
        sed -i '' "/^[^	]*	${session}	/d" "$f" 2>/dev/null ||
        grep -v "^[^	]*	${session}	" "$f" > "${f}.tmp" && mv "${f}.tmp" "$f"
      done
    fi
  done

  # 3. Trigger a fresh continuum save so the clean state is persisted
  #    (prevents autosave from writing the deleted session back)
  tmux run-shell ~/.config/tmux/plugins/tmux-continuum/scripts/continuum_save.sh 2>/dev/null || true
}
