#!/usr/bin/env python3
"""Migrate all registry skills to official .cursor/skills/<canonical>/ packages."""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

CURSOR = Path(__file__).resolve().parents[1]
SKILLS_ROOT = CURSOR / "skills"
LEGACY_ROOT = CURSOR / "features/skills/skills"
REGISTRY_PATH = LEGACY_ROOT / "registry.json"

# Do not overwrite curated SKILL.md bodies
PROTECT_SKILL_MD = frozenset(
    {
        "master",
        "skill-dispatcher",
        "api-design",
        "backend-development",
        "code-analysis",
        "fullstack-development",
        "mcp-builder",
        "security-analysis",
        "test-automation",
        "webapp-testing",
    }
)

DESCRIPTIONS: dict[str, str] = {
    "api-design": "Design RESTful, GraphQL, and microservice APIs with OpenAPI specs, consistency checks, and security review. Use when designing or reviewing API contracts, endpoints, or API documentation.",
    "backend-development": "Backend architecture, databases, APIs, caching, and deployment patterns. Use for server-side design, implementation, or review.",
    "code-analysis": "Static analysis, complexity, security patterns, and quality metrics. Use for code review, audits, or refactoring planning.",
    "fullstack-development": "End-to-end features across frontend, backend, and data layers. Use for full-stack implementation or architecture.",
    "mcp-builder": "Build MCP servers and tools for LLM integrations. Use when creating or auditing Model Context Protocol servers.",
    "security-analysis": "Security review, threat modeling, and vulnerability patterns. Use for security audits or hardening tasks.",
    "test-automation": "Automated testing strategy, CI integration, and test design. Use when building or improving test suites.",
    "webapp-testing": "Test local web apps with Playwright—E2E flows, UI debugging, screenshots, and browser logs. Use for frontend verification, regression, or VIBE test-driven workflows.",
}


def canonical_name(skill_id: str) -> str:
    return skill_id.lower().replace("_", "-")


def strip_legacy_frontmatter(text: str) -> str:
    if not text.startswith("---"):
        return text.strip()
    lines = text.splitlines()
    end = None
    for i, line in enumerate(lines[1:], 1):
        if line.strip() == "---":
            end = i
            break
    if end is None:
        return text.strip()
    return "\n".join(lines[end + 1 :]).strip()


def first_paragraph(body: str, max_len: int = 400) -> str:
    for block in re.split(r"\n\s*\n", body):
        block = block.strip()
        if block and not block.startswith("#"):
            if len(block) > max_len:
                return block[: max_len - 3].rstrip() + "..."
            return block
    return "See references/full-guide.md for the complete workflow."


def build_description(skill_id: str, entry: dict) -> str:
    c = canonical_name(skill_id)
    if c in DESCRIPTIONS:
        return DESCRIPTIONS[c]
    cn_desc = (entry.get("description") or "").strip()
    cn_name = (entry.get("name") or skill_id).strip()
    category = (entry.get("category") or "general").strip()
    if cn_desc:
        return (
            f"{cn_desc} ({cn_name}; category: {category}). "
            "Use when the user's task matches this skill domain."
        )
    return f"Project skill {c} (category: {category}). Use when the task matches this domain."


def build_skill_md(name: str, description: str, summary: str) -> str:
    title = name.replace("-", " ").title()
    return f"""---
name: {name}
description: {description}
---

# {title}

{summary}

## When to use

- User or task matches this skill's domain (see description above).
- Invoked via `/skill-name` or when the agent selects this skill from context.

## Instructions

1. Read **`references/full-guide.md`** in this skill directory for full workflows, examples, and checklists (progressive disclosure).
2. Run scripts under **`scripts/`** when present, using paths relative to this skill folder.
3. For Master orchestration: `/master skill:{name}` when the project uses the command center.

## Related

- Package root: `.cursor/skills/{name}/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`
"""


def resolve_legacy_path(entry: dict) -> Path:
    rel = entry.get("path") or f"{canonical_name(entry.get('_id', ''))}.md"
    return LEGACY_ROOT / rel


def migrate_one(skill_id: str, entry: dict) -> str:
    canonical = canonical_name(skill_id)
    skill_dir = SKILLS_ROOT / canonical
    skill_dir.mkdir(parents=True, exist_ok=True)
    refs = skill_dir / "references"
    refs.mkdir(exist_ok=True)

    legacy_path = resolve_legacy_path(entry)
    summary = "See references/full-guide.md for the complete workflow."

    if legacy_path.is_file():
        body = strip_legacy_frontmatter(legacy_path.read_text(encoding="utf-8"))
        (refs / "full-guide.md").write_text(
            f"# {canonical.replace('-', ' ').title()} — Full Guide\n\n{body}\n",
            encoding="utf-8",
        )
        summary = first_paragraph(body)
        status = "migrated"
    else:
        if not (refs / "full-guide.md").is_file():
            (refs / "full-guide.md").write_text(
                f"# {canonical}\n\nLegacy source missing: `{legacy_path.relative_to(CURSOR.parent)}`\n",
                encoding="utf-8",
            )
        status = "stub"

    skill_md = skill_dir / "SKILL.md"
    if canonical in PROTECT_SKILL_MD and skill_md.is_file():
        return f"skip-skill-md:{canonical}"

    desc = build_description(skill_id, entry)
    skill_md.write_text(build_skill_md(canonical, desc, summary), encoding="utf-8")
    return status


def update_registry(legacy: dict) -> None:
    for skill_id, entry in legacy.items():
        canonical = canonical_name(skill_id)
        rel_path = entry.get("path", f"{skill_id}.md")
        entry["legacy_path"] = rel_path
        entry["package"] = f".cursor/skills/{canonical}/SKILL.md"
        entry["guide"] = f".cursor/skills/{canonical}/references/full-guide.md"
        entry["canonical_id"] = canonical
        entry["path"] = f"skills/{rel_path}"
        entry["deprecated_flat_md"] = True
    data = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
    data["last_updated"] = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    data["description"] = (
        "Cursor AI Rules 技能注册表 — 官方包位于 .cursor/skills/；"
        "legacy 扁平 .md 已归档，path 字段仅供索引"
    )
    data["skills"]["legacy"] = legacy
    REGISTRY_PATH.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


def main() -> None:
    registry = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
    legacy: dict = registry["skills"]["legacy"]
    stats: dict[str, int] = {}
    for skill_id, entry in sorted(legacy.items()):
        result = migrate_one(skill_id, entry)
        stats[result] = stats.get(result, 0) + 1
        print(f"{skill_id} -> {canonical_name(skill_id)}: {result}")

    update_registry(legacy)
    print(f"\nRegistry updated: {REGISTRY_PATH}")
    print(f"Stats: {stats}")
    print(f"Packages under: {SKILLS_ROOT}")


if __name__ == "__main__":
    main()
