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

## Subagents

`claude/agents/` holds seven topical agents, symlinked to `~/.claude/agents`.
`install.sh` links the directory, so an agent you create with `/agents` lands in
this repository.

| Agent | Model | Scope |
|---|---|---|
| `locate` | haiku | Finds where code lives. Read-only. Uses `ast-grep` where a repository configures it. |
| `test-runner` | sonnet | Runs pytest, go test, ruff, mypy, and fixes the failures. |
| `notebook-analyst` | sonnet | Notebooks, datasets, DVC pipelines, metric runs. |
| `go-dev` | sonnet | Go code in orquesta-lite. |
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
