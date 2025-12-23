#!/bin/bash

# Tmux shell aliases

alias tm=tmux

tmux-sessions-restore() {
  while IFS= read -r session; do
    session_name="${session%%=*}"
    session_cwd="$(envsubst <<< "${session#*=}")"
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
      echo "Init session [$session_name] at [$session_cwd]"
      tmux new-session -d -s "$session_name" -c "$session_cwd"
    fi
  done < ~/.tmux-sessions.properties
}
