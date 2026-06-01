---
name: mcp-builder
description: Build MCP servers and tools for LLM integrations (Node/Python). Use when scaffolding MCP servers, defining tools/resources, or connecting external APIs via MCP.
---

# MCP Builder

Guidance for production-quality MCP servers: tool design, auth, error handling, and SDK usage.

## When to use

- New MCP server for an API or internal service
- Extending existing MCP with tools/resources
- Security review of MCP exposure

## Workflow

1. Define tools, inputs/outputs, and auth model.
2. Scaffold with official SDK (Node or Python).
3. Implement handlers with validation and structured errors.
4. Test with MCP inspector / Cursor client.

## References

- Skill: `.cursor/features/skills/skills/mcp-builder.md`
- Spec samples: `.cursor/features/skills/skills/reference/mcp-specification.md`
- Registry: `legacy.mcp-builder`
