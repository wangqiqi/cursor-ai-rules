---
name: mcp-builder
description: Build MCP servers and tools for LLM integrations. Use when creating or auditing Model Context Protocol servers.
---

# Mcp Builder

Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. Use when building MCP servers to integrate external APIs or services, whether in Python (FastMCP) or Node/TypeScript (MCP SDK).

## When to use

- User or task matches this skill's domain (see description above).
- Invoked via `/skill-name` or when the agent selects this skill from context.

## Instructions

1. Read **`references/full-guide.md`** in this skill directory for full workflows, examples, and checklists (progressive disclosure).
2. Run scripts under **`scripts/`** when present, using paths relative to this skill folder.
3. For Master orchestration: `/master skill:mcp-builder` when the project uses the command center.

## Related

- Package root: `.cursor/skills/mcp-builder/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`
