---
name: skill-creator
description: Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.
---

# 🎯 Skill Creator

Guide for creating effective skills that extend AI agents' capabilities with specialized knowledge, workflows, or tool integrations.

## When to Use

- Use this skill when users want to create a new skill (or update an existing skill)
- This skill is helpful for extending Claude's capabilities with domain-specific knowledge
- When building specialized workflows or tool integrations
- For creating reusable knowledge packages that can be shared across projects

## Instructions

### Skill Creation Guidelines

1. **Define Clear Scope**: Each skill should have a focused, well-defined purpose
2. **Write Comprehensive Instructions**: Include detailed guidance on when and how to use the skill
3. **Include Examples**: Provide concrete examples of the skill in action
4. **Document Dependencies**: List any required tools, libraries, or prerequisites
5. **Test Thoroughly**: Ensure the skill works reliably in different contexts

### Skill Structure Best Practices

- **Frontmatter**: Include name and description in YAML frontmatter
- **Clear Title**: Use descriptive titles that explain the skill's purpose
- **When to Use Section**: Provide clear triggers for when the skill should be activated
- **Instructions Section**: Detail step-by-step guidance for the agent
- **Examples**: Include practical usage examples where possible

### Distribution and Sharing

Skills can be:
- Stored locally in `.cursor/skills/` directories
- Shared via GitHub repositories
- Packaged for distribution to other Cursor users

## Examples

### Creating a Basic Skill

```markdown
---
name: my-custom-skill
description: Handle specific task category with specialized knowledge
---

# My Custom Skill

Description of what this skill does...

## When to Use

- When users need help with [specific task]
- In [specific context or scenario]

## Instructions

1. Step-by-step guidance
2. Best practices
3. Common patterns
```

## License

Complete terms in LICENSE.txt

---
*Source: Anthropic Skills Library | Integrated: 2026-01-15*