#!/usr/bin/env python3
"""Polish .cursor/skills: English descriptions, remove legacy path mentions."""

from __future__ import annotations

import json
import re
from pathlib import Path

CURSOR = Path(__file__).resolve().parents[1]
SKILLS_ROOT = CURSOR / "skills"
REGISTRY = CURSOR / "features/skills/skills/registry.json"

# Curated English descriptions (Cursor Agent Skills best practice: clear, when-to-use)
DESCRIPTIONS: dict[str, str] = {
    "algorithmic-art": "Create algorithmic art and interactive p5.js visualizations. Use when generating generative art, creative coding, or visual experiments.",
    "api-design": "Design RESTful, GraphQL, and microservice APIs with OpenAPI specs, consistency checks, and security review. Use when designing or reviewing API contracts, endpoints, or API documentation.",
    "api-testing": "Plan and implement API testing with contracts, mocks, and automation. Use when validating endpoints, integration tests, or API quality gates.",
    "backend-development": "Backend architecture, databases, APIs, caching, and deployment patterns. Use for server-side design, implementation, or review.",
    "brand-guidelines": "Apply brand colors, typography, and voice consistently. Use when aligning UI or content with brand standards.",
    "canvas-design": "Create canvas-based graphics and visual layouts. Use for poster-like designs, graphics, or canvas-driven UI assets.",
    "code-analysis": "Static analysis, complexity, security patterns, and quality metrics. Use for code review, audits, or refactoring planning.",
    "code-examples": "Produce clear, runnable code examples and snippets. Use when documenting APIs, tutorials, or reference implementations.",
    "code-formatting": "Format and style code consistently across languages and linters. Use when standardizing style, applying formatters, or fixing lint noise.",
    "debug-assistant": "Systematic debugging, root-cause analysis, and fix verification. Use when investigating bugs, failures, or unexpected behavior.",
    "doc-coauthoring": "Co-author documents with structured outlines, reviews, and iteration. Use for specs, proposals, or collaborative writing.",
    "documentation-tools": "Author and maintain technical documentation, READMEs, and API docs. Use when writing or restructuring project docs.",
    "docx": "Create and edit Microsoft Word documents with formatting and structure. Use for .docx generation, templates, or document automation.",
    "evaluation": "Evaluate MCP servers and agent tools with structured test cases and metrics. Use when benchmarking tools or validation suites.",
    "frontend-design": "Build distinctive, production-grade web UI with strong visual design. Use for landing pages, dashboards, components, or styling web interfaces.",
    "fullstack-development": "End-to-end features across frontend, backend, and data layers. Use for full-stack implementation or architecture.",
    "git-management": "Git workflows, branching, commits, and collaboration practices. Use for version control setup, merges, or release hygiene.",
    "internal-comms": "Draft internal announcements, updates, and team communications. Use for status reports, memos, or internal messaging.",
    "learning-assistant": "Explain concepts, study plans, and guided learning paths. Use when teaching, onboarding, or breaking down complex topics.",
    "mcp-builder": "Build MCP servers and tools for LLM integrations. Use when creating or auditing Model Context Protocol servers.",
    "mcp-specification": "Reference MCP protocol specification and compliance details. Use when implementing or reviewing MCP against the spec.",
    "mcp-best-practices": "Apply MCP security, design, and operational best practices. Use when hardening or reviewing MCP server design.",
    "node-mcp-server": "Implement MCP servers in Node.js/TypeScript. Use for Node-based MCP scaffolding, tools, and transports.",
    "optimization-tools": "Profile and optimize performance, bundles, and resource usage. Use when improving speed, memory, or build size.",
    "pdf": "Extract, create, and manipulate PDF documents. Use for PDF parsing, forms, merging, or document pipelines.",
    "performance-analysis": "Measure and improve application performance and bottlenecks. Use for profiling, load issues, or latency work.",
    "pptx": "Create and edit PowerPoint presentations programmatically. Use for slide decks, templates, or presentation automation.",
    "python-sdk-readme": "Use the Python MCP SDK patterns and APIs. Use when building Python MCP clients or servers with the official SDK.",
    "python-mcp-server": "Implement MCP servers in Python. Use for Python MCP scaffolding, tools, and stdio/HTTP transports.",
    "refactoring-tools": "Safe refactors, structure improvements, and technical debt reduction. Use when restructuring code without behavior change.",
    "reference-readme": "Navigate MCP reference documentation and README conventions. Use when locating official MCP reference material.",
    "security-analysis": "Security review, threat modeling, and vulnerability patterns. Use for security audits or hardening tasks.",
    "skill-creator": "Author new Agent Skills with proper structure and descriptions. Use when creating or updating SKILL.md packages.",
    "slack-gif-creator": "Create animated GIFs optimized for Slack. Use when generating short animations or Slack-ready media.",
    "ssr-optimization": "Optimize server-side rendering, hydration, and SSR frameworks. Use for Next.js/Nuxt SSR performance or SEO rendering.",
    "system-analysis": "Analyze system architecture, dependencies, and operational boundaries. Use for architecture reviews or system mapping.",
    "test-automation": "Automated testing strategy, CI integration, and test design. Use when building or improving test suites.",
    "theme-factory": "Generate and apply multi-theme design tokens and palettes. Use when theming apps or creating theme variants.",
    "typescript-sdk-readme": "Use the TypeScript MCP SDK patterns and APIs. Use when building TS MCP clients or servers.",
    "vulnerability-scanning": "Scan dependencies and code for known vulnerabilities. Use for CVE checks, SCA, or security gates in CI.",
    "web-artifacts-builder": "Build self-contained HTML/React artifacts for previews and demos. Use for standalone web artifacts or Claude-style widgets.",
    "webapp-testing": "Test local web apps with Playwright—E2E flows, UI debugging, screenshots, and browser logs. Use for frontend verification or regression.",
    "xlsx": "Create and edit Excel spreadsheets with formulas and formatting. Use for .xlsx generation, reports, or spreadsheet automation.",
    "master": "Master command center: intent routing, rules/skills orchestration, and 21 AI personas. Use when invoking /master or unified project orchestration.",
    "skill-dispatcher": "Discover and route to project skills under .cursor/skills. Use when matching tasks to skills or listing available skills.",
}

SKIP_BODY_REWRITE = frozenset({"master", "skill-dispatcher"})

RELATED_BLOCK = """## Related

- Package root: `.cursor/skills/{name}/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`"""


def canonical(skill_id: str) -> str:
    return skill_id.lower().replace("_", "-")


def fallback_description(skill_id: str, entry: dict) -> str:
    cn = (entry.get("description") or "").strip()
    cat = (entry.get("category") or "general").strip()
    return (
        f"{cn} Use when the task fits category '{cat}'."
        if cn
        else f"Project skill for {canonical(skill_id)}."
    )


def polish_skill_md(path: Path, name: str, description: str) -> bool:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return False

    m = re.match(r"^---\n.*?\n---\n", text, re.S)
    if not m:
        return False

    body = text[m.end() :]
    new_fm = f"---\nname: {name}\ndescription: {description}\n---\n"

    body = re.sub(
        r"\n## Related\n.*?(?=\n## |\Z)",
        "\n" + RELATED_BLOCK.format(name=name) + "\n",
        body,
        count=1,
        flags=re.S,
    )
    if "## Related" not in body:
        body = body.rstrip() + "\n\n" + RELATED_BLOCK.format(name=name) + "\n"

    body = re.sub(
        r"Registry metadata: `\.cursor/references/full-guide\.md`",
        "Registry metadata: `.cursor/features/skills/skills/registry.json`",
        body,
    )

    path.write_text(new_fm + body, encoding="utf-8")
    return True


def main() -> None:
    registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
    legacy = registry["skills"]["legacy"]
    updated = 0

    for skill_md in sorted(SKILLS_ROOT.glob("*/SKILL.md")):
        name = skill_md.parent.name
        skill_id = None
        entry = {}
        for sid, ent in legacy.items():
            if canonical(sid) == name:
                skill_id = sid
                entry = ent
                break

        desc = DESCRIPTIONS.get(name) or (
            fallback_description(skill_id, entry)
            if skill_id
            else f"Project skill: {name}."
        )

        if name in SKIP_BODY_REWRITE:
            text = skill_md.read_text(encoding="utf-8")
            if "## Related" in text or "features/skills" in text:
                polish_skill_md(skill_md, name, DESCRIPTIONS.get(name, desc))
                updated += 1
            continue

        polish_skill_md(skill_md, name, desc)
        updated += 1
        print(f"polished: {name}")

    print(f"\nDone: {updated} SKILL.md files under {SKILLS_ROOT}")


if __name__ == "__main__":
    main()
