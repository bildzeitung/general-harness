#!/bin/bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

cost_fmt=""
[ -n "$cost" ] && cost_fmt=$(printf '$%.2f' "$cost")
duration_sec=$((duration_ms / 1000))
mins=$((duration_sec / 60))
secs=$((duration_sec % 60))


ps1_part=$(printf "\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m" "$cwd")

extras=""
[ -n "$model" ] && extras="$extras $model"
[ -n "$used" ] && extras="$extras ctx:$(printf '%.0f' "$used")%"
[ -n "$cost_fmt" ] && extras="$extras 💰 $cost_fmt"
[ "$duration_sec" -gt 0 ] 2>/dev/null && extras="$extras ⏱️ ${mins}m ${secs}s"

printf "%s%s\n" "$ps1_part" "$extras"
