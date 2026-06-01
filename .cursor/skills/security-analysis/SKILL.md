---
name: security-analysis
description: Analyze code for security vulnerabilities and suggest fixes—OWASP-style review, secrets, injection, and auth flaws. Use during security reviews or before release.
---

# Security Analysis

Static and architectural security review: common CWE classes, dependency risks, and hardening recommendations.

## When to use

- Pre-merge security pass on sensitive changes
- Auth/session/crypto configuration review
- Incident or audit follow-up

## Checklist (abbreviated)

- Input validation and output encoding
- AuthZ on every protected path
- Secrets not in repo; least-privilege credentials
- Dependency/CVE scan where applicable

## Full reference

`.cursor/features/skills/skills/security-analysis.md`  
Registry: `legacy.security-analysis`
