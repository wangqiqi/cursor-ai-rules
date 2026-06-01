---
name: performance-analysis
description: Measure and improve application performance and bottlenecks. Use for profiling, load issues, or latency work.
---

# Performance Analysis

页面加载时间:
- < 1s: 优秀
- 1-3s: 良好
- 3-5s: 可接受
- > 5s: 需要优化
```

## When to use

- User or task matches this skill's domain (see description above).
- Invoked via `/skill-name` or when the agent selects this skill from context.

## Instructions

1. Read **`references/full-guide.md`** in this skill directory for full workflows, examples, and checklists (progressive disclosure).
2. Run scripts under **`scripts/`** when present, using paths relative to this skill folder.
3. For Master orchestration: `/master skill:performance-analysis` when the project uses the command center.

## Related

- Package root: `.cursor/skills/performance-analysis/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`
