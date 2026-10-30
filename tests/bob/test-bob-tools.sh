#!/usr/bin/env bash
# Validate the IBM Bob tool mapping and the SKILL.md pointer to it.
#
# Mirrors tests/antigravity/test-antigravity-tools.sh. CI-safe: does not
# require Bob installed.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

MAPPING="$REPO_ROOT/skills/using-superpowers/references/bob-tools.md"
SKILL="$REPO_ROOT/skills/using-superpowers/SKILL.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

echo "test-bob-tools: checking IBM Bob tool mapping"

[ -f "$MAPPING" ] || fail "tool mapping missing at $MAPPING"

# --- Core action→tool mappings are documented -------------------------------
for tool in read_file write_file apply_diff search_and_replace insert_content \
            execute_command grep glob list_files use_skill spawn_subagent \
            update_todo_list ask_followup_question; do
  grep -q "\`$tool\`" "$MAPPING" \
    || fail "mapping does not document the '$tool' tool"
done

# --- Subagent dispatch documents Bob's built-in types -----------------------
grep -q '`general`' "$MAPPING" \
  || fail "mapping does not document the 'general' subagent type"
grep -q '`explore`' "$MAPPING" \
  || fail "mapping does not document the 'explore' subagent type"

# --- SKILL.md Platform Adaptation links the mapping -------------------------
grep -q "references/bob-tools.md" "$SKILL" \
  || fail "SKILL.md Platform Adaptation does not reference bob-tools.md"

echo "PASS: IBM Bob tool mapping valid (core tools, subagent types, SKILL.md link)"
