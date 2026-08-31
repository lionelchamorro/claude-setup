# claude-setup

Claude Code configuration: settings, writing style, and a roster of topical
subagents. Shared across machines and with the team.

See `ONBOARDING.md` for the version to hand to somebody new.

## Install

    git clone git@github.com:lionelchamorro/claude-setup.git ~/Projects/claude-setup
    ~/Projects/claude-setup/install.sh

`install.sh` needs `jq`. It backs up any existing `~/.claude/CLAUDE.md` and
`~/.claude/agents` before it replaces them with symlinks, so an edit in this
repository is live at once.

`~/.claude/settings.json` is different: `install.sh` merges it instead of linking
it. Re-run `install.sh` after you change `claude/settings.json` here. See
"Machine-specific parts".

## What is configured

| Setting | Value | Reason |
|---|---|---|
| `model` | `claude-opus-5` | Pinned to Opus 5 at a 200K window. Avoids the long-context price tier above 200K. |
| `env.CLAUDE_CODE_SUBAGENT_MODEL` | `sonnet` | Subagents ran 47% of the spend on Opus. Search and exploration do not need Opus. |
| `attribution.commit` | `""` | Removes the `Co-Authored-By` trailer from commits. |
| `autoCompactWindow` | `300000` | Caps the context window at 300K. Autocompact fires below that, after the summary buffer. |

`CLAUDE.md` sets the response style to ASD-STE100 Simplified Technical English,
mirroring the language the user writes in.

## Subagents

`claude/agents/` holds six topical agents, symlinked to `~/.claude/agents`.
`install.sh` links the directory, so an agent you create with `/agents` lands in
this repository.

| Agent | Model | Scope |
|---|---|---|
| `locate` | haiku | Finds where code lives. Read-only. Uses `ast-grep` where a repository configures it. |
| `test-runner` | sonnet | Runs pytest, go test, ruff, mypy, and fixes the failures. |
| `notebook-analyst` | sonnet | Notebooks, datasets, DVC pipelines, metric runs. |
| `developer` | sonnet | Application code in any language. Builds and runs the tests. |
| `infra` | sonnet | docker-compose, k8s, service wiring. |
| `reviewer` | opus | Adversarial pre-PR review. Read-only. |
| `docs` | haiku | Documentation in Simplified Technical English. |

Model precedence for a subagent, highest first:

1. The `model` argument of the tool call
2. The `model` field in the agent frontmatter
3. `CLAUDE_CODE_SUBAGENT_MODEL`
4. The parent session model

The env var is therefore a floor, not an override. An agent that declares `opus`
gets Opus. Anything that declares nothing falls back to Sonnet.

`CLAUDE.md` carries the table that says which agent covers which task.

## Machine-specific parts

This repository does not carry the `hooks` and `statusLine` keys. Orca owns them.

Orca is the desktop app that runs agent CLIs in panes. To draw the state of each
pane, it registers `~/.orca/agent-hooks/claude-hook.sh` on ten Claude Code events
and on the status line. The script posts each event to a port on localhost.

Orca rewrites those two keys in `~/.claude/settings.json` on every start. It
builds the script path from the home directory of the machine and writes it as an
absolute path in single quotes. It offers no environment variable to change that
path, and it emits no `$HOME` form. A symlink would therefore carry one machine's
home directory into this repository, and a hand-edited path would come back to
the absolute form at the next start.

`install.sh` keeps `hooks` and `statusLine` from the file already on the machine
and overlays every other key from this repository. Orca manages its own block per
machine. On a machine without Orca, the two keys are simply absent.

## Notes on precedence

Claude Code reads settings in this order, highest first:

1. `/etc/claude-code/managed-settings.json`
2. CLI arguments
3. `.claude/settings.local.json` in the project
4. `.claude/settings.json` in the project
5. `~/.claude/settings.json` (merged from this repo)

A project can therefore override anything here.
