#!/usr/bin/env zsh
# ~/.cx.sh
# Source this in your ~/.zshrc:  source ~/.cx.sh

# ─── helpers ────────────────────────────────────────────────────────────────

# Get the project name from the current session name (strips -cN suffix)
_cx_project_from_session() {
  if [ -n "$TMUX" ]; then
    tmux display-message -p "#{session_name}" | sed 's/-c[0-9]*$//'
  else
    basename "$(pwd)"
  fi
}

# Attach or switch to a session
_cx_attach() {
  local session=$1
  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}

# ─── cx — create next session in current dir ────────────────────────────────

cx() {
  local dir=$(pwd)
  local project=$(basename "$dir")

  # Find next available cN number
  local n=1
  while tmux has-session -t "${project}-c${n}" 2>/dev/null; do
    (( n++ ))
  done

  local session="${project}-c${n}"

  echo "→ Creating session: $session"

  tmux new-session -d -s "$session" -c "$dir"

  # Window 1: nvim
  tmux rename-window -t "$session:1" "nvim"
  tmux send-keys -t "$session:1" "nvim ." Enter

  # Window 2: shell (empty terminal in same dir)
  tmux new-window -t "$session" -n "shell" -c "$dir"

  # Window 3: opencode
  tmux new-window -t "$session" -n "opencode" -c "$dir"
  tmux send-keys -t "$session:3" "opencode" Enter

  # Start on nvim
  tmux select-window -t "$session:1"

  _cx_attach "$session"
}

# ─── cxd — detach from current session ──────────────────────────────────────

cxd() {
  if [ -z "$TMUX" ]; then
    echo "Not inside a tmux session."
    return 1
  fi
  tmux detach-client
}

# ─── cx1..cx9 — switch to cN of current project ─────────────────────────────

_cx_switch() {
  local n=$1
  local project=$(_cx_project_from_session)
  local target="${project}-c${n}"

  if tmux has-session -t "$target" 2>/dev/null; then
    _cx_attach "$target"
  else
    echo "✗ No session: $target"
    echo "  Available:"
    tmux list-sessions -F "  #{session_name}" 2>/dev/null \
      | grep "^  ${project}-c"
  fi
}

cx1() { _cx_switch 1; }
cx2() { _cx_switch 2; }
cx3() { _cx_switch 3; }
cx4() { _cx_switch 4; }
cx5() { _cx_switch 5; }
cx6() { _cx_switch 6; }
cx7() { _cx_switch 7; }
cx8() { _cx_switch 8; }
cx9() { _cx_switch 9; }

# ─── cxx1..cxx9 — kill cN with confirmation ──────────────────────────────────

_cx_kill() {
  local n=$1
  local project=$(_cx_project_from_session)
  local target="${project}-c${n}"

  if ! tmux has-session -t "$target" 2>/dev/null; then
    echo "✗ No session: $target"
    return 1
  fi

  echo -n "Kill \"$target\"? [y/N] "
  read confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    tmux kill-session -t "$target"
    echo "✓ Killed $target"
  else
    echo "Cancelled."
  fi
}

cxx1() { _cx_kill 1; }
cxx2() { _cx_kill 2; }
cxx3() { _cx_kill 3; }
cxx4() { _cx_kill 4; }
cxx5() { _cx_kill 5; }

# ─── cxl — list sessions for current project ────────────────────────────────

cxl() {
  local project=$(_cx_project_from_session)
  echo -e "\033[1;34mProject: $project\033[0m\n"

  local sessions
  sessions=$(tmux list-sessions -F "#{session_name}|#{session_windows}|#{?session_attached,attached,detached}" 2>/dev/null \
    | grep "^${project}-c")

  if [ -z "$sessions" ]; then
    echo "  No sessions found for this project."
  else
    echo "$sessions" | while IFS='|' read -r name windows state; do
      if [ "$state" = "attached" ]; then
        echo -e "  \033[1;32m● $name\033[0m  ($windows windows)  ← you are here"
      else
        echo "  ○ $name  ($windows windows)"
      fi
    done
  fi
  echo ""
}
