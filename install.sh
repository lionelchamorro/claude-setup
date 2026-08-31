#!/usr/bin/env bash
# Install the Claude Code config from this repo into ~/.claude.
#
# CLAUDE.md and the agents directory are symlinked, so an edit in the repo is
# live at once.
#
# settings.json is MERGED, not symlinked. Orca owns the `hooks` and `statusLine`
# keys: it rewrites them into ~/.claude/settings.json on every start, with an
# absolute path built from the home directory of the machine. A symlink would
# therefore carry one machine's paths into the repo. The merge keeps those two
# keys local and takes every other key from the repo.
#
# Existing real files are backed up to <file>.pre-dotfiles-<timestamp>.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

command -v jq >/dev/null || { echo "install.sh needs jq" >&2; exit 1; }

mkdir -p "$HOME/.claude"

backup() {
  local dest="$1"
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    mv "$dest" "$dest.pre-dotfiles-$STAMP"
    echo "backed up $dest -> $dest.pre-dotfiles-$STAMP"
  fi
}

link() {
  local src="$REPO/$1" dest="$HOME/$2"
  backup "$dest"
  ln -s "$src" "$dest"
  echo "linked $dest -> $src"
}

# Take `hooks` and `statusLine` from whatever is already on this machine, then
# overlay every key this repo defines.
merge_settings() {
  local src="$REPO/claude/settings.json" dest="$HOME/.claude/settings.json"
  local local_keys='{}' tmp

  if [ -e "$dest" ]; then
    local_keys="$(jq '{hooks, statusLine} | with_entries(select(.value != null))' "$dest")"
  fi

  tmp="$(mktemp "${TMPDIR:-/tmp}/claude-settings.XXXXXX")"
  jq -s '.[0] * .[1]' "$src" <(printf '%s' "$local_keys") > "$tmp"

  if [ -e "$dest" ] && [ ! -L "$dest" ] && cmp -s "$tmp" "$dest"; then
    rm "$tmp"
    echo "unchanged $dest"
    return
  fi

  backup "$dest"
  mv "$tmp" "$dest"
  chmod 644 "$dest"
  echo "merged $dest <- $src"
}

merge_settings
link claude/CLAUDE.md .claude/CLAUDE.md
link claude/agents    .claude/agents

echo
echo "Done. Restart running Claude Code sessions to pick up model and env changes."
echo "Re-run this script after you change claude/settings.json in the repo."
