# dotfiles

Claude Code configuration, shared across machines.

## Install

    git clone <this-repo> ~/Projects/dotfiles
    ~/Projects/dotfiles/install.sh

`install.sh` backs up any existing `~/.claude/settings.json` and `~/.claude/CLAUDE.md`
before it replaces them with symlinks.

## What is configured

| Setting | Value | Reason |
|---|---|---|
| `model` | `claude-opus-5` | Pinned to Opus 5 at a 200K window. Avoids the long-context price tier above 200K. |
| `env.CLAUDE_CODE_SUBAGENT_MODEL` | `sonnet` | Subagents ran 47% of the spend on Opus. Search and exploration do not need Opus. |
| `attribution.commit` | `""` | Removes the `Co-Authored-By` trailer from commits. |
| `autoCompactWindow` | `300000` | Caps the context window at 300K. Autocompact fires below that, after the summary buffer. |

`CLAUDE.md` sets the response style to ASD-STE100 Simplified Technical English,
mirroring the language the user writes in.

## Machine-specific parts

`settings.json` carries `hooks` and `statusLine` that call `~/.orca/agent-hooks/`.
Each command guards on the file existing, so it is inert on a machine without Orca.

## Notes on precedence

Claude Code reads settings in this order, highest first:

1. `/etc/claude-code/managed-settings.json`
2. CLI arguments
3. `.claude/settings.local.json` in the project
4. `.claude/settings.json` in the project
5. `~/.claude/settings.json` (this repo)

A project can therefore override anything here.
