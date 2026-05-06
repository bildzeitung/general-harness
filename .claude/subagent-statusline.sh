#!/bin/bash
input=$(cat)

name=$(echo "$input" | jq -r '.name // .agent_name // .type // empty')
desc=$(echo "$input" | jq -r '.description // .agent_description // empty')
tokens_used=$(echo "$input" | jq -r '.context_window.used_tokens // .tokens_used // empty')
tokens_total=$(echo "$input" | jq -r '.context_window.budget_tokens // .tokens_total // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

parts=""
[ -n "$name" ] && parts="$name"
[ -n "$desc" ] && parts="$parts | $desc"

token_str=""
if [ -n "$used_pct" ]; then
    token_str="ctx:$(printf '%.0f' "$used_pct")%"
elif [ -n "$tokens_used" ] && [ -n "$tokens_total" ]; then
    token_str="tokens:${tokens_used}/${tokens_total}"
elif [ -n "$tokens_used" ]; then
    token_str="tokens:${tokens_used}"
fi
[ -n "$token_str" ] && parts="$parts  $token_str"

[ -n "$parts" ] && printf "%s\n" "$parts"
