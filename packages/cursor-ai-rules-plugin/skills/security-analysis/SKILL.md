---
name: security-analysis
description: Security review, threat modeling, and vulnerability patterns. Use for security audits or hardening tasks.
---

# Security Analysis

提供全面的代码安全分析能力，识别潜在的安全漏洞、配置问题和最佳实践违反，保障代码的安全性和合规性。

## When to use

- User or task matches this skill's domain (see description above).
- Invoked via `/skill-name` or when the agent selects this skill from context.

## Instructions

1. Read **`references/full-guide.md`** in this skill directory for full workflows, examples, and checklists (progressive disclosure).
2. Run scripts under **`scripts/`** when present, using paths relative to this skill folder.
3. For Master orchestration: `/master skill:security-analysis` when the project uses the command center.

## Related

- Package root: `.cursor/skills/security-analysis/`
- Full guide: `references/full-guide.md`
- Registry metadata: `.cursor/features/skills/skills/registry.json`
