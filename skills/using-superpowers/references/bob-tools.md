# IBM Bob Tool Mapping

Skills speak in actions ("dispatch a subagent", "create a todo", "read a file"). On IBM Bob (IDE and Bob Shell) these resolve to the tools below.

| Action skills request | Bob equivalent |
|----------------------|----------------|
| Read a file | `read_file` |
| Create a new file / fully rewrite one | `write_file` |
| Edit a file | `apply_diff` (targeted diff), `search_and_replace` (literal or regex), `insert_content` (insert lines) |
| Delete a file | `execute_command` (`rm`, `git rm`) — Bob has no delete tool |
| Run a shell command | `execute_command` |
| Search file contents | `grep` |
| Find files by name | `glob` |
| List files and subdirectories | `list_files` |
| Fetch a URL / search the web | Off by default (`experiments.webFetch` / `experiments.webSearch`). If no web tool is listed, use an MCP server if one is configured, or `execute_command` with `curl`; otherwise report the gap |
| Invoke a skill | `use_skill` with `skill_name` |
| Dispatch a subagent (`Subagent (general-purpose):` template) | `spawn_subagent` with the `general` type (see [Subagent support](#subagent-support)) |
| Read-only codebase exploration | `spawn_subagent` with the `explore` type |
| Multiple parallel dispatches | Multiple `spawn_subagent` calls in the same response |
| Task tracking ("create a todo", "mark complete") | `update_todo_list` — always send the full checklist (`[ ]` pending, `[-]` in progress, `[x]` done) |
| Ask your human partner a question | `ask_followup_question` |
| Switch mode | `switch_mode` |

## Skill invocation

`use_skill` is Bob's skill-loading mechanism: it loads the skill's `SKILL.md` and gives access to its supporting files. Use it for every Superpowers skill. Bob lists each skill's location next to its description; files a skill references (`./implementer-prompt.md`, `references/...`) are relative to that location.

## Instructions file

When a skill mentions "your instructions file", on Bob this is **`AGENTS.md`** in the workspace root (Bob Shell also reads `~/.bob/AGENTS.md`), together with rules files in `.bob/rules/` and `~/.bob/rules/`.

## Personal skills directory

User-level skills live at **`~/.bob/skills/`**; project skills at **`.bob/skills/`**. Bob also discovers skills in `plugins/*/skills/` under either `.bob` directory, which is where Superpowers is installed.

## Modes

Run Superpowers workflows in **Agent** mode. Plan mode can only edit `.md`/`.txt` files, can only dispatch `explore` subagents, and its built-in instructions start every session with Bob's own `create-plan` skill. Ask mode cannot edit files. If a skill needs edits or a `general` subagent while you are in Plan or Ask mode, ask your human partner to switch to Agent mode (`switch_mode`).

## Subagent support

`spawn_subagent` dispatches an isolated subagent. Its tool description lists the subagent types available in the current mode:

| Type | Use for |
|------|---------|
| `general` | Implementation, review, and any filled Superpowers prompt template — full tool access |
| `explore` | Read-only codebase search; it cannot call `use_skill` or `update_todo_list` |

Set `fork_context: true` only when the subagent needs the prior conversation. Superpowers prompt templates are written to be self-contained, so leave it `false` for them.

| Skill dispatch form | Bob equivalent |
|---------------------|----------------|
| References a `*-prompt.md` template (implementer, task-reviewer, code-reviewer, etc.) | Fill the template, then `spawn_subagent` with the `general` type and the filled prompt |
| References `superpowers:requesting-code-review`'s `./code-reviewer.md` | `spawn_subagent` with the `general` type and the filled review template |
| Inline prompt (no template referenced) | `spawn_subagent` with the `general` type and your inline prompt |

Fill every placeholder (`{WHAT_WAS_IMPLEMENTED}`, `[FULL TEXT of task]`, …) before dispatching. Keep dependent tasks sequential; issue independent dispatches in the same response.

If `spawn_subagent` is not available in the current mode, do the work inline — never invent a tool call.
