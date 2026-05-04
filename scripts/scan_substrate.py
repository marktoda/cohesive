#!/usr/bin/env python3
"""
scan_substrate.py — fast inventory of candidate substrate files in a repo.

Usage:
    python3 scan_substrate.py [path] [--json | --markdown] [--max-depth N]

Defaults to current directory, markdown output, max depth 6.

Categorizes files into substrate buckets so a Cohesive skill can decide where
to look without reading the world. Output is structured and reuse-friendly.

Buckets:
    normative_docs    — CLAUDE.md, AGENTS.md, README.md, architecture.md
    design_docs       — docs/design/**, docs/specs/**, docs/adr/**
    invariant_docs    — docs/invariants/**, *invariant*.md
    gotcha_docs       — docs/gotchas/**, *gotcha*.md, *scar*.md
    behavior_matrices — *matrix*.md, *behavior-matrix*.md
    test_strategy     — docs/testing/**, TESTING.md
    tests             — tests/**, **/__tests__/**, **/*.test.* (sample)
    ci_files          — .github/workflows/**, .gitlab-ci.yml, .circleci/**
    package_files     — package.json, pyproject.toml, Cargo.toml, go.mod
    schema_files      — *.schema.json, *.proto, *.graphql, schemas/**
    migration_files   — migrations/**, db/migrate/**
    type_defs         — *.d.ts, types/**
    config            — .editorconfig, tsconfig.json, pyrightconfig.json
    custom_linters    — eslint plugins, scripts/lint*.{sh,py}
    local_commands    — Makefile, justfile, scripts/*.sh, package.json scripts
    cohesive_artifacts — docs/cohesive/**

Each entry: relative path + first non-empty line of file (for quick context).
Hidden dirs (.git, node_modules, .venv, .worktrees) are skipped.
Files larger than 2MB are skipped.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable

SKIP_DIRS = {
    ".git", "node_modules", ".venv", "venv", "__pycache__", ".worktrees",
    "worktrees", ".tox", ".mypy_cache", ".pytest_cache", "dist", "build",
    "target", ".next", ".nuxt", "out", ".turbo", ".cache", "vendor",
}
MAX_FILE_BYTES = 2 * 1024 * 1024


@dataclass
class Inventory:
    normative_docs: list[dict] = field(default_factory=list)
    design_docs: list[dict] = field(default_factory=list)
    invariant_docs: list[dict] = field(default_factory=list)
    gotcha_docs: list[dict] = field(default_factory=list)
    behavior_matrices: list[dict] = field(default_factory=list)
    test_strategy: list[dict] = field(default_factory=list)
    tests: list[dict] = field(default_factory=list)
    ci_files: list[dict] = field(default_factory=list)
    package_files: list[dict] = field(default_factory=list)
    schema_files: list[dict] = field(default_factory=list)
    migration_files: list[dict] = field(default_factory=list)
    type_defs: list[dict] = field(default_factory=list)
    config: list[dict] = field(default_factory=list)
    custom_linters: list[dict] = field(default_factory=list)
    local_commands: list[dict] = field(default_factory=list)
    cohesive_artifacts: list[dict] = field(default_factory=list)


def walk(root: Path, max_depth: int) -> Iterable[Path]:
    root = root.resolve()
    root_depth = len(root.parts)
    for dirpath, dirnames, filenames in os.walk(root):
        depth = len(Path(dirpath).parts) - root_depth
        if depth >= max_depth:
            dirnames[:] = []
            continue
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".") or d in {".github", ".circleci", ".gitlab-ci.yml"}]
        for f in filenames:
            yield Path(dirpath) / f


def first_nonempty_line(path: Path) -> str:
    try:
        if path.stat().st_size > MAX_FILE_BYTES:
            return f"<{path.stat().st_size} bytes — skipped>"
        with path.open("r", encoding="utf-8", errors="replace") as fh:
            for line in fh:
                s = line.strip()
                if s and not s.startswith(("---", "//", "#!", "<!--")):
                    return s[:140]
            return ""
    except OSError:
        return ""


def classify(path: Path, root: Path, inv: Inventory) -> None:
    rel = path.relative_to(root).as_posix()
    name = path.name.lower()
    parts = [p.lower() for p in path.relative_to(root).parts]
    entry = {"path": rel, "first_line": first_nonempty_line(path)}

    # Cohesive artifacts (must come before generic docs)
    if "cohesive" in parts and parts[0] == "docs":
        inv.cohesive_artifacts.append(entry)
        return

    # Normative top-level docs
    if name in {"claude.md", "agents.md", "readme.md", "architecture.md", "contributing.md"} and len(parts) == 1:
        inv.normative_docs.append(entry)
        return

    # docs subtrees
    if parts and parts[0] == "docs":
        if any(p in {"design", "specs", "adr", "rfc", "rfcs"} for p in parts):
            inv.design_docs.append(entry)
            return
        if any(p == "invariants" for p in parts) or "invariant" in name:
            inv.invariant_docs.append(entry)
            return
        if any(p in {"gotchas", "scars", "incidents"} for p in parts) or "gotcha" in name or "scar" in name:
            inv.gotcha_docs.append(entry)
            return
        if any(p == "testing" for p in parts):
            inv.test_strategy.append(entry)
            return
        if "matrix" in name:
            inv.behavior_matrices.append(entry)
            return
        # Other docs treated as design adjacent
        if name.endswith(".md"):
            inv.design_docs.append(entry)
            return

    # Behavior matrix files anywhere
    if "matrix" in name and name.endswith(".md"):
        inv.behavior_matrices.append(entry)
        return

    # Tests (sample — cap total)
    if any(p in {"tests", "test", "__tests__", "spec", "specs"} for p in parts) or any(name.endswith(s) for s in (".test.ts", ".test.js", ".test.tsx", ".test.jsx", ".spec.ts", ".spec.js", "_test.go", "_test.py", ".test.py")):
        if len(inv.tests) < 50:
            inv.tests.append(entry)
        return

    # CI
    if parts[:2] == ["github", "workflows"] or parts[:2] == [".github", "workflows"] or any(p == ".circleci" for p in parts) or name in {".gitlab-ci.yml", ".travis.yml", "azure-pipelines.yml"}:
        inv.ci_files.append(entry)
        return
    if len(parts) == 1 and name == ".github":
        return  # handled by walk

    # Schemas
    if name.endswith((".proto", ".graphql", ".graphqls")) or ".schema." in name or any(p in {"schemas", "schema"} for p in parts):
        inv.schema_files.append(entry)
        return

    # Migrations
    if any(p in {"migrations", "migrate", "db"} for p in parts) and (name.endswith((".sql", ".py", ".rb", ".ts", ".js")) or "migrate" in name):
        inv.migration_files.append(entry)
        return

    # Type defs
    if name.endswith(".d.ts") or (parts and parts[0] in {"types", "@types"} and name.endswith((".ts", ".d.ts"))):
        inv.type_defs.append(entry)
        return

    # Package/manifest
    if name in {"package.json", "pyproject.toml", "cargo.toml", "go.mod", "gemfile", "pom.xml", "build.gradle", "build.gradle.kts", "deno.json"} and len(parts) == 1:
        inv.package_files.append(entry)
        return

    # Config
    if name in {".editorconfig", "tsconfig.json", "pyrightconfig.json", ".eslintrc.json", ".eslintrc.js", ".prettierrc", "ruff.toml"} or name.startswith(".eslintrc"):
        inv.config.append(entry)
        return

    # Custom linters / check scripts
    if parts and parts[0] == "scripts" and (name.startswith(("lint", "check", "validate")) or "lint" in name):
        inv.custom_linters.append(entry)
        return

    # Local commands
    if name in {"makefile", "justfile", "tasks.py", "noxfile.py"} and len(parts) == 1:
        inv.local_commands.append(entry)
        return
    if parts and parts[0] == "scripts" and name.endswith((".sh", ".py", ".js", ".ts")):
        inv.local_commands.append(entry)
        return


def render_markdown(inv: Inventory, root: Path) -> str:
    lines = [f"# Substrate scan: {root}", ""]
    sections = [
        ("Normative docs", inv.normative_docs),
        ("Design docs / specs / ADRs", inv.design_docs),
        ("Invariant docs", inv.invariant_docs),
        ("Gotcha / scar docs", inv.gotcha_docs),
        ("Behavior matrices", inv.behavior_matrices),
        ("Test strategy docs", inv.test_strategy),
        ("Tests (sample, capped at 50)", inv.tests),
        ("CI files", inv.ci_files),
        ("Package / manifest files", inv.package_files),
        ("Schema files", inv.schema_files),
        ("Migration files", inv.migration_files),
        ("Type definitions", inv.type_defs),
        ("Config", inv.config),
        ("Custom linters / check scripts", inv.custom_linters),
        ("Local commands", inv.local_commands),
        ("Cohesive artifacts (docs/cohesive/**)", inv.cohesive_artifacts),
    ]
    for title, items in sections:
        lines.append(f"## {title}")
        if not items:
            lines.append("_none found_")
            lines.append("")
            continue
        for e in items:
            fl = e["first_line"]
            if fl:
                lines.append(f"- `{e['path']}` — {fl}")
            else:
                lines.append(f"- `{e['path']}`")
        lines.append("")
    return "\n".join(lines)


def main() -> int:
    p = argparse.ArgumentParser(description="Inventory substrate files in a repo.")
    p.add_argument("path", nargs="?", default=".")
    p.add_argument("--json", action="store_true")
    p.add_argument("--markdown", action="store_true")
    p.add_argument("--max-depth", type=int, default=6)
    args = p.parse_args()

    root = Path(args.path).resolve()
    if not root.is_dir():
        print(f"Error: {root} is not a directory", file=sys.stderr)
        return 2

    inv = Inventory()
    for path in walk(root, args.max_depth):
        try:
            classify(path, root, inv)
        except Exception:
            continue

    if args.json:
        out = {k: v for k, v in inv.__dict__.items()}
        print(json.dumps(out, indent=2))
    else:
        print(render_markdown(inv, root))
    return 0


if __name__ == "__main__":
    sys.exit(main())
