# Superpowers for IBM Bob

Guide for using Superpowers with [IBM Bob](https://bob.ibm.com/docs/ide) — the
Bob IDE and Bob Shell (`bob`).

## Requirements

- Bob IDE **2.2.0 or later** (plugin directories). 2.3.0 or later is recommended:
  it makes plugin skills follow the plugin's enabled/disabled state.
- Bob Shell 2.0.9 or later, if you use the CLI.
- `git`.

## How it works

Bob loads *plugin directories* at startup: every folder in
`~/.bob/plugins/<plugin-name>/` (global) or `.bob/plugins/<plugin-name>/`
(workspace). Superpowers is installed by cloning this repository as one of those
folders. Bob then picks up two things from it:

| File in the clone | What Bob does with it |
|---|---|
| `skills/*/SKILL.md` | Registers each Superpowers skill. Bob lists every skill's name and description in the system prompt, and the model loads one with the `use_skill` tool. |
| `rules-agent/superpowers.md` | A mode rule for **Agent** mode. Bob adds rules to the system prompt on every request, so it is present from the first message and after context compaction. It tells the model to load `using-superpowers` before responding, and replaces Bob's default "only activate skills that are clearly relevant" guidance with Superpowers' rule. |

Nothing is written to your Bob settings, rules, or `AGENTS.md`.

## Install

Global install (all workspaces) — recommended:

```bash
git clone https://github.com/obra/superpowers ~/.bob/plugins/superpowers
```

Windows (PowerShell):

```powershell
git clone https://github.com/obra/superpowers "$env:USERPROFILE\.bob\plugins\superpowers"
```

Workspace install (one project only, e.g. to share with a team):

```bash
git clone https://github.com/obra/superpowers .bob/plugins/superpowers
```

A workspace install is subject to **workspace trust**: in an untrusted folder,
Bob suspends workspace skills and rules until you trust the folder.

Restart Bob (or open a new Bob window) after installing — plugins are read on
startup.

## Required configuration in the Bob IDE

These three settings decide whether Bob actually follows the skills. Do them
once, after installing.

### 1. Auto-approve skills

By default Bob asks for permission every time it activates a skill. Bob's own
built-in skills are exempt; Superpowers skills are not. Every Superpowers
workflow loads several skills, so without this the session stalls on approval
prompts — and a rejected prompt means the skill's instructions never reach the
model.

1. Open the Bob panel.
2. Click the **Settings** icon in the Bob panel to open **Bob Settings**.
3. Go to the **Auto-Approve** section.
4. Turn on the toggle for **Skills**.

### 2. Check that the skills are loaded and enabled

1. In **Bob Settings**, open the **Skills** tab.
2. Confirm the Superpowers skills are listed (`brainstorming`,
   `test-driven-development`, `systematic-debugging`, `using-superpowers`, …)
   with a location under `.bob/plugins/superpowers/skills/`.
3. Make sure they are enabled. From Bob 2.3.0, plugin skills follow the
   plugin's enabled/disabled state, so if the skills show as disabled, enable
   the `superpowers` plugin.

If they are missing, Bob did not see the plugin folder: check the clone path
(`~/.bob/plugins/superpowers/skills/brainstorming/SKILL.md` must exist) and
restart Bob.

### 3. Work in Agent mode

Select **Agent** mode in the Bob chat panel's mode selector (Agent is Bob's
default mode).

The Superpowers bootstrap rule is scoped to Agent mode, and Agent mode is the
only built-in mode that can run Superpowers end to end:

- **Plan** mode's built-in instructions always start with Bob's own
  `create-plan` skill, it can only edit `.md`/`.txt` files, and it can only
  dispatch read-only `explore` subagents.
- **Ask** mode cannot edit files.

Superpowers covers planning itself (`brainstorming` → `writing-plans`), so you
don't need Plan mode for it.

If you use **custom modes**, the bootstrap rule does not apply to them. Give the
mode the `skill` tool group, and copy `rules-agent/superpowers.md` into a
`rules-<your-mode-slug>/` folder next to your `custom_modes.yaml` (Bob Settings →
**Modes** tab manages custom modes).

## Bob Shell

Bob Shell reads the same plugin directories, so the install above covers it too.

Skills still need approval in Bob Shell. To auto-approve them, add `"skill"` to
`approval.allowed_permissions` in your `~/.bob/settings/settings.json`:

```json
{
  "approval": {
    "allowed_permissions": ["skill"]
  }
}
```

Bob merges this with its defaults (`read` stays allowed). Start sessions in
Agent mode (`--mode agent`, the default).

## Verify

Start a **new** Bob chat in Agent mode.

Smoke check — ask:

```
What are your superpowers?
```

Bob should call `use_skill` for `using-superpowers` and describe the Superpowers
skills.

Acceptance test — in a fresh chat, send exactly:

```
Let's make a react todo list
```

Bob should load `using-superpowers`, then `brainstorming`, and start asking you
design questions **before writing any code**.

## Updating

```bash
git -C ~/.bob/plugins/superpowers pull
```

Restart Bob afterwards.

## Uninstalling

Delete `~/.bob/plugins/superpowers` (or `.bob/plugins/superpowers`) and restart
Bob.

## Troubleshooting

**Bob starts coding without loading any skill.**
Check, in order: you are in Agent mode; Skills auto-approve is on (otherwise
look for a pending approval prompt in the chat); the skills appear in Bob
Settings → Skills; `~/.bob/plugins/superpowers/rules-agent/superpowers.md`
exists. Then start a new chat — rules and skills are read when a chat starts.

**The same skill appears twice in Bob Settings → Skills.**
Bob also discovers skills in `~/.bob/skills/`, `~/.agents/skills/`, and
`~/.claude/skills/` (and their `.bob/`, `.agents/`, `.claude/` workspace
equivalents). If you copied Superpowers skills into one of those, remove the
copies so only the plugin's skills are loaded.

**Web fetch / web search are missing.**
They are experimental in Bob and off by default (`experiments.webFetch`,
`experiments.webSearch`). The few skills that use them degrade without them.

## Getting help

- Report issues: https://github.com/obra/superpowers/issues
- Tool mapping used by the skills on Bob:
  [`skills/using-superpowers/references/bob-tools.md`](../skills/using-superpowers/references/bob-tools.md)
