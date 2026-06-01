---
name: learning-assistant
description: Explain concepts, study plans, and guided learning paths. Use when teaching, onboarding, or breaking down complex topics.
---

# Learning Assistant

中级:
├── You Don't Know JS (书籍系列)
├── JavaScript设计模式
├── Web性能优化
└── Node.js实战项目

## When to use

- User or task matches this skill's domain (see description above).
- Invoked via `/skill-name` or when the agent selects this skill from context.

## Instructions

1. Read **`references/full-guide.md`** in this skill directory for full workflows, examples, and checklists (progressive disclosure).
2. Run scripts under **`scripts/`** when present, using paths relative to this skill folder.
3. For Master orchestration: `/master skill:learning-assistant` when the project uses the command center.

## Related

- Package root: `.cursor/skills/learning-assistant/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`
