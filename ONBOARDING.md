# Claude Code setup — collectiveai

Repository: `git@github.com:lionelchamorro/claude-setup.git`

This guide sets up Claude Code the way the team runs it. It takes about two minutes.

## Why this exists

A usage review showed three cost drivers:

- 68% of spend ran above a 150K context.
- 61% came from sessions that spawned many subagents.
- 47% came from `general-purpose` subagents alone, all on Opus.

The settings below address each one. They also remove the `Co-Authored-By` trailer
from commits and set a shared writing style.

## 1. User settings

Add these keys to `~/.claude/settings.json`. Keep any hooks, plugins, or status line
you already have.

```json
{
  "model": "claude-opus-5",
  "env": {
    "CLAUDE_CODE_SUBAGENT_MODEL": "sonnet"
  },
  "attribution": {
    "commit": ""
  },
  "autoCompactWindow": 300000
}
```

| Key | Effect |
|---|---|
| `model` | Pins Opus 5 at a 200K window. The `opus[1m]` variant bills a premium rate above 200K. |
| `env.CLAUDE_CODE_SUBAGENT_MODEL` | Runs subagents on Sonnet. Search and exploration do not need Opus. |
| `attribution.commit` | An empty string removes the commit attribution trailer. |
| `autoCompactWindow` | Caps the context at 300K. Autocompact fires below that, after the summary buffer. |

`autoCompactWindow` accepts 100000 to 1000000. The effective window is
`min(model_window, autoCompactWindow)`. Change it per session with `/autocompact`.

## 2. Writing style

Add this to `~/.claude/CLAUDE.md`:

```markdown
## Writing style

Mirror the user's language, and apply ASD-STE100 Simplified Technical English.
When the user writes in English, use strict ASD-STE100. When the user writes in
another language, answer in that language and apply the STE principles below to it.

- One idea per sentence. Procedures: max 20 words. Descriptions: max 25 words.
- Use the active voice. Name the agent of every action.
- Use one approved word per meaning, and one meaning per word. Do not use synonyms
  for variety.
- Use simple present, simple past, or simple future. Avoid `-ing` forms as verbs.
- Do not omit articles or the word `that`. Keep noun clusters to 3 words or less.
- Start an instruction with the verb. Put the condition before the instruction.
- No idioms, no jargon beyond the technical names of the tools and code at hand.

This applies to chat responses, commit messages, and PR descriptions. It does not
apply to code, code comments, or file contents, which follow the conventions of the
surrounding codebase.
```

## 3. When the settings take effect

| Change | Sessions that already run |
|---|---|
| `autoCompactWindow` | Yes, at the start of the next turn. |
| `attribution` | Yes, at the next commit. |
| `model` | No. Run `/model claude-opus-5`, or restart the session. |
| `env` | No. Restart the session. |
| `CLAUDE.md` | No. Restart the session. |

Restart your long-running sessions. The `model` and `env` keys carry most of the
saving, and both need a restart.

## 4. Repository settings

Some repositories carry a `.claude/settings.json` of their own. `botica` is the
first one. It sets `attribution` and `autoCompactWindow` for everybody, and it
denies reads of `.env` files and private keys.

Repository settings override your user settings. They do not set `model` or
`env`, so your own choice of model still applies.

## 5. Topical subagents

Run `install.sh` from this repository, or copy `claude/agents/` into `~/.claude/agents/`.

Seven agents replace the default `general-purpose` agent for the work this team
does. Each one declares its own tools and its own model.

| Agent | Model | Scope |
|---|---|---|
| `locate` | haiku | Finds where code lives. Read-only. |
| `test-runner` | sonnet | Runs pytest, go test, ruff, mypy, and fixes the failures. |
| `notebook-analyst` | sonnet | Notebooks, datasets, DVC pipelines, metric runs. |
| `go-dev` | sonnet | Go code in orquesta-lite. |
| `infra` | sonnet | docker-compose, k8s, service wiring. |
| `reviewer` | opus | Adversarial pre-PR review. Read-only. |
| `docs` | haiku | Documentation. |

`general-purpose` inherits every tool and the parent model. It caused 47% of the
spend. `locate` covers most of that work on Haiku instead.

Model precedence, highest first: the tool call, then the agent frontmatter, then
`CLAUDE_CODE_SUBAGENT_MODEL`, then the parent model. The env var is a floor.

## 6. Habits that cut cost

- Run `/clear` when you change task. A new task does not need the old context.
- Run `/compact` when a task grows long but you still need its result.
- Spawn a subagent when you need a conclusion, not a file dump. Each subagent
  runs its own requests.
- Watch sessions that run for 8 or more hours. Background loops accumulate cost.

Check your own numbers with `/usage`.
