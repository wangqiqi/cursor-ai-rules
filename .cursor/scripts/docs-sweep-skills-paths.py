#!/usr/bin/env python3
"""Sweep docs: replace obsolete features/skills flat .md paths with official packages."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

SKIP_PARTS = {
    "archive",
    "node_modules",
    ".git",
    "CHANGELOG.md",  # keep historical wording
}

GLOBS = [
    ".cursor/docs/**/*.md",
    ".cursor/agents/**/*.md",
    ".cursor/skills/skill-dispatcher/README.md",
    ".cursor/skills/skill-dispatcher/examples.md",
    ".cursor/README.en.md",
    "README.en.md",
    "ROADMAP.md",
    "AGENTS.md",
    "README.md",
]

LEGACY_MD = re.compile(r"\.cursor/features/skills/skills/([a-zA-Z0-9_-]+)\.md")


def canonical(skill_file: str) -> str:
    return skill_file.lower().replace("_", "-")


def replace_legacy_md(text: str) -> str:
    return LEGACY_MD.sub(
        lambda m: f".cursor/skills/{canonical(m.group(1))}/references/full-guide.md",
        text,
    )


def sweep_text(text: str) -> str:
    text = replace_legacy_md(text)
    text = text.replace(
        ".cursor/features/skills/skills/reference/",
        ".cursor/skills/",
    )
    # reference/readme style paths after partial replace
    text = re.sub(
        r"\.cursor/skills/([a-zA-Z0-9_-]+)-README\.md",
        lambda m: f".cursor/skills/{canonical(m.group(1))}/references/full-guide.md",
        text,
    )
    text = text.replace(
        "`.cursor/features/skills/[skill-name].md`",
        "`.cursor/skills/<skill-name>/references/full-guide.md`",
    )
    text = text.replace(
        "`.cursor/features/skills/*.md`",
        "`.cursor/skills/*/SKILL.md` + `references/full-guide.md`",
    )
    text = text.replace(
        "`.cursor/features/skills/*.md` - 技能文件",
        "`.cursor/skills/*/SKILL.md` — 官方技能包",
    )
    text = text.replace(
        "扫描 `.cursor/features/skills/` 目录",
        "扫描 `.cursor/skills/` 目录",
    )
    text = text.replace(
        "正在扫描 .cursor/features/skills/ 目录",
        "正在扫描 .cursor/skills/ 目录",
    )
    text = text.replace(
        "`.cursor/features/skills/` 目录中的技能",
        "`.cursor/skills/` 官方技能包",
    )
    text = text.replace(
        "调用 `.cursor/features/skills/` 目录中的技能",
        "调度 `.cursor/skills/` 官方技能包",
    )
    text = text.replace(
        "自动扫描 `.cursor/features/skills/` 目录",
        "扫描 `.cursor/skills/*/SKILL.md`",
    )
    text = text.replace(
        "📍 技能目录: /path/to/.cursor/features/skills/",
        "📍 技能目录: /path/to/.cursor/skills/",
    )
    text = text.replace(
        "在 `.cursor/features/skills/` 创建技能文件",
        "在 `.cursor/skills/<name>/` 创建官方技能包（`SKILL.md` + `references/full-guide.md`）",
    )
    text = text.replace(
        "技能文件: .cursor/features/skills/some-skill.md",
        "技能正文: .cursor/skills/some-skill/references/full-guide.md",
    )
    text = text.replace("37个技能", "45 个技能包")
    text = text.replace("37 个技能", "45 个技能包")
    text = text.replace("(37个技能)", "(45 个技能包)")
    text = text.replace("**数量**: 37个技能", "**数量**: 45 个技能包")
    text = text.replace(
        ".cursor/features/skills/* (37个技能)",
        ".cursor/skills/* (45 个官方技能包)",
    )
    text = text.replace(
        "features/skills/reference/mcp_best_practices.md",
        ".cursor/skills/mcp-best-practices/references/full-guide.md",
    )
    text = text.replace(
        "`.cursor/features/skills/skills/reference/python-sdk-README.md`",
        "`.cursor/skills/python-sdk-readme/references/full-guide.md`",
    )
    text = text.replace(
        "加载 `.cursor/features/skills/*.md` 并应用",
        "加载 `.cursor/skills/<name>/references/full-guide.md` 并应用",
    )
    text = text.replace(
        "`.cursor/features/skills/skills/registry.json` - 技能元数据（唯一数据源）",
        "`.cursor/features/skills/skills/registry.json` — 元数据索引；正文在 `.cursor/skills/*/references/full-guide.md`",
    )
    return text


def main() -> None:
    changed = []
    for pattern in GLOBS:
        for path in ROOT.glob(pattern):
            if any(p in path.parts for p in SKIP_PARTS):
                continue
            if path.name == "SKILL.md":
                continue
            old = path.read_text(encoding="utf-8")
            new = sweep_text(old)
            if new != old:
                path.write_text(new, encoding="utf-8")
                changed.append(path.relative_to(ROOT))
    print(f"Updated {len(changed)} files:")
    for p in sorted(changed):
        print(f"  - {p}")


if __name__ == "__main__":
    main()
