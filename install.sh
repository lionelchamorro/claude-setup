#!/usr/bin/env bash
# Symlink the Claude Code config from this repo into ~/.claude.
# Links settings.json, CLAUDE.md, and the agents directory.
# Existing real files are backed up to <file>.pre-dotfiles-<timestamp>.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$HOME/.claude"

link() {
  local src="$REPO/$1" dest="$HOME/$2"
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    mv "$dest" "$dest.pre-dotfiles-$STAMP"
    echo "backed up $dest -> $dest.pre-dotfiles-$STAMP"
  fi
  ln -s "$src" "$dest"
  echo "linked $dest -> $src"
}

link claude/settings.json .claude/settings.json
link claude/CLAUDE.md     .claude/CLAUDE.md
link claude/agents        .claude/agents

echo
echo "Done. Restart running Claude Code sessions to pick up model and env changes."
