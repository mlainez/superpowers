#!/usr/bin/env bash
# Validate that a clone of this repo works as an IBM Bob plugin directory
# (~/.bob/plugins/superpowers/): Bob discovers skills/*/SKILL.md, and loads
# rules-agent/* into the Agent-mode system prompt on every request.
#
# CI-safe: does not require Bob installed.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

RULE="$REPO_ROOT/rules-agent/superpowers.md"
MAPPING="$REPO_ROOT/skills/using-superpowers/references/bob-tools.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

echo "test-bob-plugin-layout: checking IBM Bob plugin layout"

# --- Bootstrap rule ---------------------------------------------------------
[ -f "$RULE" ] || fail "bootstrap rule missing at $RULE"
grep -q '<EXTREMELY_IMPORTANT>' "$RULE" \
  || fail "bootstrap rule is not wrapped in <EXTREMELY_IMPORTANT>"
grep -q 'skill_name: "using-superpowers"' "$RULE" \
  || fail "bootstrap rule does not load using-superpowers via use_skill"
grep -q 'references/bob-tools.md' "$RULE" \
  || fail "bootstrap rule does not point at references/bob-tools.md"
[ -f "$MAPPING" ] || fail "bootstrap rule points at a missing $MAPPING"

# A root-level rules/ directory would also be loaded by Cursor and Antigravity.
[ ! -e "$REPO_ROOT/rules" ] \
  || fail "root rules/ is shared with other harnesses; keep Bob rules in rules-agent/"

# --- Skills meet Bob's discovery rules --------------------------------------
# Folder names are lowercase kebab-case (<= 64 chars) and match `name`;
# skills without a description are ignored; descriptions over 1024 chars are
# truncated in the skill list.
count=0
for skill_md in "$REPO_ROOT"/skills/*/SKILL.md; do
  dir="$(basename "$(dirname "$skill_md")")"
  [[ "$dir" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ && ${#dir} -le 64 ]] \
    || fail "skill folder '$dir' is not lowercase kebab-case <= 64 chars"
  name="$(awk -F': *' '/^name:/{print $2; exit}' "$skill_md")"
  [ "$name" = "$dir" ] || fail "skills/$dir: name '$name' does not match folder"
  desc="$(awk '/^description:/{sub(/^description: */, ""); print; exit}' "$skill_md")"
  [ -n "$desc" ] || fail "skills/$dir: missing description"
  [ "${#desc}" -le 1024 ] || fail "skills/$dir: description over 1024 chars"
  count=$((count + 1))
done
[ "$count" -gt 0 ] || fail "no skills found under skills/"

# --- Rule stays out of the Codex plugin sync --------------------------------
grep -q '"/rules-agent/"' "$REPO_ROOT/scripts/sync-to-codex-plugin.sh" \
  || fail "sync-to-codex-plugin.sh does not exclude /rules-agent/"

echo "PASS: IBM Bob plugin layout valid ($count skills, Agent-mode bootstrap rule)"
