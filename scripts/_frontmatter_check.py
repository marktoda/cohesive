#!/usr/bin/env python3
"""Frontmatter validation helper for validate_plugin.sh.

Reads a markdown file's YAML frontmatter and checks that:
  - The file opens with `---` on line 1.
  - The frontmatter has a closing `---`.
  - `name:` is present and matches the expected name argument.
  - `description:` is present and non-empty.

Exits 0 with no output on success.
Exits 1 on failure with a single-line error message naming the failure.

Usage:
    python3 scripts/_frontmatter_check.py <file.md> <expected_name>

Called from scripts/validate_plugin.sh; not intended to be invoked directly
from skills or agents. The bash script orchestrates which files to check; this
helper does the actual YAML parsing so the bash code stays out of awk-state-
machine territory.
"""
from __future__ import annotations

import sys
from pathlib import Path


def parse_frontmatter(path: Path) -> dict[str, str] | None:
    """Return the parsed frontmatter as a dict, or None if malformed.

    Supports plain `key: value` lines and `key: |` block scalars (the agent
    description form). Does not attempt full YAML — Cohesive frontmatter is
    intentionally narrow.
    """
    text = path.read_text()
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None

    body: list[str] = []
    closed = False
    for line in lines[1:]:
        if line.strip() == "---":
            closed = True
            break
        body.append(line)
    if not closed:
        return None

    fields: dict[str, str] = {}
    i = 0
    while i < len(body):
        line = body[i]
        if not line.strip() or line.lstrip().startswith("#"):
            i += 1
            continue
        if ":" not in line:
            i += 1
            continue
        key, _, value = line.partition(":")
        key = key.strip()
        value = value.strip()
        if value == "|":
            block_lines: list[str] = []
            i += 1
            while i < len(body) and (body[i].startswith(" ") or body[i].startswith("\t") or not body[i].strip()):
                block_lines.append(body[i])
                i += 1
            fields[key] = "\n".join(block_lines).strip()
        else:
            fields[key] = value
            i += 1
    return fields


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <file.md> <expected_name>", file=sys.stderr)
        return 2

    path = Path(sys.argv[1])
    expected_name = sys.argv[2]

    if not path.is_file():
        print(f"{path}: file not found")
        return 1

    fm = parse_frontmatter(path)
    if fm is None:
        print(f"{path}: missing or malformed --- frontmatter")
        return 1

    if "name" not in fm:
        print(f"{path}: missing 'name:' frontmatter field")
        return 1
    if fm["name"] != expected_name:
        print(f"{path}: frontmatter name '{fm['name']}' does not match expected '{expected_name}'")
        return 1
    if "description" not in fm or not fm["description"].strip():
        print(f"{path}: missing or empty 'description:' frontmatter field")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
