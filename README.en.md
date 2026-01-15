# 🚀 Cursor AI Rules - Make AI Your Super Programming Partner

[![Cursor](https://img.shields.io/badge/Cursor-AI-blue?style=for-the-badge&logo=cursor&logoColor=white)](https://cursor.com)
[![Version](https://img.shields.io/badge/version-4.2.0-green?style=for-the-badge)](https://github.com/wangqiqi/cursor-ai-rules/releases)
[![License](https://img.shields.io/badge/license-MIT-yellow?style=for-the-badge)](LICENSE)

[![Bootstrap](https://img.shields.io/badge/bootstrap-3-blue?style=flat-square)]()
[![Rules](https://img.shields.io/badge/rules-16-green?style=flat-square)]()
[![Skills](https://img.shields.io/badge/skills-16-9cf?style=flat-square)]()
[![Automation](https://img.shields.io/badge/automation-8-orange?style=flat-square)]()

🌍 **[English](README.en.md) | [中文](README.md)**

**🌟 Revolutionary AI Programming Collaboration Experience - Let AI Truly Understand Your Project and Needs**

[📖 Documentation](#-cursor-ai-rules---make-ai-your-super-programming-partner) • [🚀 Quick Start](#-quick-start-60-seconds-setup) • [💡 Features](#-core-features) • [🤝 Contribute](#-contribution-methods)

---

## ✨ Why Choose Cursor AI Rules?

🤖 **Pain Points of Traditional AI Collaboration:**
- AI often gives generic suggestions, lacking project context
- Unable to understand your team standards and coding style
- Insufficient security considerations, prone to security risks
- Need to repeatedly adjust AI output to meet requirements

🎯 **Cursor AI Rules Solutions:**
- 🔍 **Intelligent Perception** - Auto-analyze your project structure, tech stack, and team dynamics
- 🧠 **Adaptive Learning** - Continuously optimize collaboration patterns based on your habits
- 🛡️ **Security Guarantee** - Built-in risk control and privacy protection mechanisms
- ⚡ **Plug-and-Play** - 3-minute deployment, immediately boost AI collaboration efficiency

> **"This rule system truly made AI my programming partner, not just a generic assistant"** - From early user feedback

## ✨ Core Features

### 🚀 Plug-and-Play
```bash
# One-click deploy to any project
./.cursor/cursor-adaptation-setup.sh

# Run intelligent perception analysis
./.cursor/rules/intelligent_evolution/perception.sh
```

### 🚀 Adaptive Bootstrap System
- **🔍 Intelligent Environment Detection** - Auto-identify tech stack, team size, project maturity
- **⚙️ Auto Configuration Generation** - Generate personalized configs based on detection results
- **📦 On-Demand Skill Installation** - Install only AI skills needed by the project
- **🎯 Intelligent Rule Activation** - Auto-enable relevant rules based on project characteristics

### 🧠 Intelligent Collaboration Framework
- **🎯 Intelligent Master Controller** - Auto-perceive demands and intelligently execute internal commands
- **🤝 AI Symbiosis Constitution** - Core principles and highest standards of human-AI collaboration
- **💬 Collaboration Philosophy** - Intelligent dialogue patterns and communication optimization
- **🧠 Intelligent Evolution System** - Unified coordination of auto-perception and rule evolution
- **📈 Evolution Philosophy** - Core principles and guidance for rule evolution
- **📋 Manual Evolution Process** - Artificial trigger and rule evolution management
- **🤖 Automated Evolution System** - Intelligent rule optimization based on perception data
- **🛡️ Evolution Governance** - Security assurance and quality control for rule evolution
- **⚙️ Project Rules Generator** - Automated personalized rule configuration generation
- **🔧 System Information Retriever** - Auto-acquire time, path and author information
- **🎨 Configuration Templates** - Automated project initialization configuration
- **🔍 ESLint Code Quality Check** - Auto-detect and fix JavaScript code issues

### 🎨 Hierarchical Configuration System
- **🌐 Global Configuration Templates** - System-level default settings
- **🏗️ Project Configuration Generation** - Auto-generated based on environment
- **👤 User Custom Overrides** - Personalized settings override
- **🔄 Intelligent Configuration Merge** - Auto-resolve configuration conflicts

### ⚙️ Automation Script Engine
- **🎣 Event-Driven Hooks** - 7 automated hook scripts
- **🛠️ Manual Tool Scripts** - 8 general maintenance scripts
- **🔧 Adaptive Configuration** - Adjust behavior based on project environment
- **📊 Performance Monitoring** - Real-time monitoring and optimization

### 🧠 Intelligent Features

- ✅ **Intelligent Master** - Natural language driven, auto-analyze intent and execute optimal solutions
- ✅ **Auto-Perception** - Real-time monitoring of project changes and tech stack evolution
- ✅ **User Learning** - Analyze communication patterns, learn collaboration preferences
- ✅ **Adaptive Adjustment** - Auto-optimize rules based on perception data
- ✅ **Progressive Evolution** - Small steps, fast iterations, ensure smooth transition
- ✅ **Perception Analysis** - Run `./.cursor/rules/intelligent_evolution/perception.sh` to get project insights
- ✅ **Out-of-the-Box** - No configuration needed, copy and use, support any project, any language

### 🔧 Adaptive Environment
- 🔍 **Auto Environment Detection** - Get local time, Git info, and project status
- 🎯 **Intelligent Rule Matching** - Auto-adjust based on project type and tech stack
- 📝 **Template Variable Replacement** - Dynamic variable system, ready to use
- 🛡️ **Secure Collaboration Guarantee** - Risk control and privacy protection
- 📊 **Usage Statistics Monitoring** - Real-time perception and performance analysis

### 🎣 Cursor Hooks Integration

> **🚀 v4.2.0 New Feature** - Deep integration with Cursor's official Hooks system, providing enterprise-grade AI collaboration security

Cursor Hooks is a powerful extension mechanism provided by Cursor officially, allowing you to observe, control, and extend AI collaboration processes through custom scripts. Cursor AI Rules deeply integrates with the Hooks system, providing comprehensive security monitoring and quality assurance:

#### 🛡️ Security & Audit Hooks
- **🔒 Command Security Audit** - Automatically block dangerous shell commands to protect system security
- **📊 Execution Logging** - Record all commands and operations executed by AI for easy audit tracking
- **🚫 Sensitive Content Detection** - Detect and block prompts containing sensitive information like API keys
- **⚠️ Risk Assessment** - Real-time risk assessment for high-risk operations

#### 🔍 Quality Assurance Hooks
- **🎨 Auto Code Formatting** - Automatically run ESLint, Prettier, etc. after AI code edits
- **🐍 Multi-Language Support** - Support JavaScript/TypeScript, Python, Go, Rust, and other languages
- **📏 Quality Gates** - Code quality checks to ensure compliance with team coding standards

#### 📈 Analytics & Optimization Hooks
- **📋 Rule Usage Tracking** - Monitor AI rule system usage to optimize collaboration patterns
- **📊 Performance Monitoring** - Track response times and resource usage
- **🎯 Session Analytics** - Generate session summary reports to analyze AI collaboration effectiveness

#### ⚙️ Simple Configuration

The Hooks system works out-of-the-box, just ensure the `.cursor/hooks.json` configuration file exists:

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [{ "command": ".cursor/hooks/code-quality.sh" }],
    "beforeShellExecution": [{ "command": ".cursor/hooks/security-audit.sh" }],
    "afterAgentResponse": [{ "command": ".cursor/hooks/rule-usage-tracker.sh" }]
  }
}
```

#### 📊 Monitoring Dashboard

All Hooks activities are logged in the `.cursorGrowth/logs/` directory, where you can view:
- `security-events.log` - Security event records
- `command-execution.log` - Command execution statistics
- `rule-usage.log` - Rule usage analysis
- `session-summary.md` - Session summary reports

> **💡 Tip**: The Hooks system is fully compatible with the existing Cursor AI Rules system, working together to provide dual assurance

## 📺 Effect Demonstration

<div align="center">

### 🎬 Intelligent Collaboration Example

<table>
<tr>
<td width="50%">

**Traditional AI Collaboration**
```
User: "Refactor this user authentication module"

AI: Here's a standard authentication flow...
- Add password hashing
- Use JWT tokens
- Basic error handling

(Generic suggestions, lacking project context)
```

</td>
<td width="50%">

**Cursor AI Rules Collaboration**
```
User: "Refactor this user authentication module"

AI: 🧠 Perceived your project uses Node.js + MongoDB...
     👥 Single developer mode, focus on rapid iteration...
     🔒 According to constitution rules, recommended:

     ✅ Integrate bcrypt for password hashing
     ✅ Use jsonwebtoken for token generation
     ✅ Add rate limiting to prevent brute force
     ✅ Log audit trails to MongoDB
     ✅ Implement two-factor authentication option

(Project-customized suggestions)
```

</td>
</tr>
</table>

</div>

---

## 🏆 User Reviews

<div align="center">

> **"This system completely changed my coding approach. AI now truly understands my project!"**
> — *Frontend Developer, Well-known Internet Company*

> **"From skepticism to dependency, only took 3 days. Strongly recommend to all Cursor users!"**
> — *Full-stack Engineer, Open Source Contributor*

> **"Team collaboration efficiency improved by 40%, AI can now provide suggestions that match our standards"**
> — *Technical Team Lead*

</div>

---

### 📊 Project Health Metrics

<div align="center">

| 📊 Metric                   | 🎯 Status        | 📈 Trend                    |
| -------------------------- | --------------- | -------------------------- |
| **Universality**           | Any Project     | ✅ Out-of-the-box           |
| **Language Support**       | Multi-language  | 🔍 Auto-detection           |
| **Deployment Time**        | <5 seconds      | ⚡ Plug-and-play            |
| **Rule Coverage**          | 14 Rule Modules | 🛡️ Comprehensive Protection |
| **Intelligent Perception** | Activated       | 🧠 Continuous Learning      |

</div>

## 🚀 Quick Start (60-Second Setup)

<div align="center">

### ⚡ Three-Step Installation, Experience Immediately

```bash
# 1⃣ Get rules package (copy .cursor directory to project root)
cp -r /path/to/cursor-ai-rules/.cursor /path/to/your-project/

# Or clone from Git repository:
# git clone <your-repo-url> cursor-ai-rules
# cp -r cursor-ai-rules/.cursor your-project/

# 2⃣ Enter project and run adaptation
cd your-project
./.cursor/cursor-adaptation-setup.sh

# 3⃣ 🎉 Done! AI now truly understands your project
```

### 💬 Test Immediately

#### Method 1: Use Intelligent Master in Cursor Chat
```bash
@master I want to create a React project
@master Need to optimize code quality
@master Help me analyze the current project status
```

AI will auto-perceive and execute:
```
🎯 Intelligent Master Controller Activated
🧠 Analyzing user intent...
🔍 Perceiving project environment...
⚡ Auto-executing: env_check → enable → generator
```

#### Method 2: Traditional Questioning
> *"Help me optimize this API security"*

AI will immediately respond:
```
🤖 Based on constitution rules, I need to ensure data security...
     🔒 Add JWT authentication and input validation
     🛡️ Implement rate limiting to prevent brute force attacks
     📊 Add audit logging for login attempts
```

### 🔍 Unlock More Features

```bash
# Run intelligent perception to understand the full project picture
./.cursor/rules/intelligent_evolution/perception.sh

# Check environment integrity
./.cursor/scripts/env_check.sh
```

</div>

## 📋 Rules System

| Rule Module               | Function Description                             | Application Scenarios                                             | Status          |
| ------------------------- | ------------------------------------------------ | ----------------------------------------------------------------- | --------------- |
| **master**                | 🎯 Intelligent Master Controller                  | Auto-perceive demands and intelligently execute internal commands | ✅ Always Active |
| **constitution**          | 🤝 AI Symbiosis Constitution                      | Define collaboration core principles and highest standards        | ✅ Always Active |
| **philosophy**            | 💬 Communication Philosophy & Collaboration Modes | Optimize dialogue patterns and interaction optimization           | ✅ Always Active |
| **intelligent_evolution** | 🧠 Intelligent Evolution System                   | Unified coordination of auto-perception and rule evolution        | ✅ Active        |
| **evolution-philosophy**  | 📈 Evolution Philosophy                           | Core principles and guidance for rule evolution                   | ✅ Active        |
| **evolution-manual**      | 📋 Manual Evolution Process                       | Artificial trigger and rule evolution management                  | ✅ Active        |
| **evolution-automation**  | 🤖 Automated Evolution System                     | Intelligent optimization based on perception data                 | ✅ Active        |
| **evolution-governance**  | 🛡️ Evolution Governance                           | Security assurance and quality control for rule evolution         | ✅ Active        |
| **generator**             | ⚙️ Project Rules Generator                        | Automated personalized rule configuration generation              | ✅ Active        |
| **system_info**           | 🔧 System Information Retriever                   | Auto-acquire time, path and author information                    | ✅ Always Active |
| **templates**             | 🎨 Configuration Templates                        | Automated project initialization configuration                    | ✅ Active        |
| **eslint**                | 🔍 ESLint Code Quality Check                      | Auto-detect and fix JavaScript code issues                        | ✅ Always Active |
| **i18n**                  | 🌍 Internationalization Support                   | Auto-detect language preferences and switch communication         | ✅ Always Active |
| **platform_adapter**      | 🔧 Cross-platform Adapter                         | Unified management of commands, paths and environments            | ✅ Always Active |
| **module_manager**        | 📋 Rule Management System                         | Manage rule dependencies, activation control and extensions       | ✅ Always Active |
| **master**                | 🎯 Intelligent Master Controller                  | Auto-perceive demands and intelligently execute internal commands | ✅ Always Active |

### 🎯 Adaptive Skills System

**16 Professional Skills Libraries** - Support on-demand installation, intelligent matching of project needs:

#### 🧠 Intelligent Skill Matching
- **🔍 Environment Perception**: Auto-detect tech stack and project requirements
- **🎯 On-Demand Installation**: Install only project-related skills
- **📦 Skills Marketplace**: Support installation of new skills from skill registry
- **🔄 Auto-Updates**: Skill version management and updates

#### Skills Classification System

| Category             | Skills Count | Applicable Scenarios             |
| -------------------- | ------------ | -------------------------------- |
| **🧠 Core Skills**   | 3            | Basic functions for all projects |
| **💻 Tech Skills**   | 11           | Professional skills for specific tech stacks |
| **🛠️ Tool Skills**   | 5            | Development tools and platform integration |
| **🔄 Workflow Skills**| 4            | Development processes and quality assurance |

#### Core Skills (Auto-Installation)
- **Code Quality Check** - Automated code inspection after file editing
- **Security Audit** - Security verification before command execution
- **Skill Creator** - AI skill development and customization tools

#### Tech Skills (On-Demand Installation)
- **Node.js** - JavaScript/TypeScript/React/Vue development
- **Python** - Django/FastAPI data science development
- **Go** - Microservices and high-performance applications
- **Java** - Spring enterprise applications
- **.NET** - C# enterprise applications
- **PHP** - Web application development
- **Ruby** - Rails full-stack development

#### Tool Skills (Conditional Installation)
- **Docker** - Containerized deployment and orchestration
- **Kubernetes** - Container orchestration and management
- **AWS/Azure/GCP** - Cloud platform integration
- **Terraform** - Infrastructure as Code

#### Workflow Skills (Project Maturity Related)
- **Test Automation** - Unit testing, integration testing, E2E testing
- **CI/CD Pipeline** - Automated build and deployment
- **Documentation Generation** - API docs and project documentation
- **Security Scanning** - Code security and dependency checks

#### 🛠️ Skill Management Tools

```bash
# View available skills
.cursor/automation/scripts/skill-list.sh

# Install skills for current project
.cursor/automation/scripts/skill-install.sh

# Update skill versions
.cursor/automation/scripts/skill-update.sh
```

## 🏆 Core Advantages

<div align="center">

| Feature                    | Traditional Solutions           | Cursor AI Rules                           |
| -------------------------- | ------------------------------- | ----------------------------------------- |
| **Interaction Method**     | Memorize command syntax         | 🎯 Natural language driven                 |
| **Execution Mode**         | Manually call multiple commands | ⚡ Intelligent decision auto-execution     |
| **Environment Adaptation** | Manual Configuration            | 🔄 Auto-perceive project environment       |
| **Collaboration Patterns** | Fixed Rules                     | 🎯 Smart adjustment based on team size     |
| **Learning Ability**       | No Memory                       | 🧠 Continuous learning of user preferences |
| **Deployment Complexity**  | High                            | ⚡ 60-second copy-and-use                  |

</div>

## 🎨 AI Collaboration Effect Showcase

<div align="center">

### 💬 Dialogue Examples

| Scenario                  | Traditional AI                                                  | Cursor AI Rules                                                                                      |
| ------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| **Smart Demand Handling** | "I want to make a project" → Manually execute multiple commands | `@master I want to make a project` → Auto-perceive and execute complete process                      |
| **New API**               | "Write a login API" → Generic template                          | "Write a login API" → Project-customized solution, integrate existing auth framework                 |
| **Code Refactoring**      | "Refactor this function" → Standard suggestions                 | "Refactor this function" → Customized refactoring strategy based on project complexity and team size |
| **Architecture Decision** | "How to design caching" → Generic comparison                    | "How to design caching" → Optimized suggestions combining project tech stack                         |

### ⚡ Instant Perception

After running `./.cursor/rules/intelligent_evolution/perception.sh`, AI immediately understands:

- 🛠️ **Your Tech Stack** - Node.js + React + MongoDB
- 👥 **Team Collaboration Mode** - Single developer, rapid iteration
- 📊 **Project Maturity** - Early development stage
- 🎯 **Customized Suggestions** - Optimized for your specific needs

</div>


### 💻 Contribution Methods

#### 🚀 Code Contributions
```bash
# 1. Fork and clone (repo URL: https://github.com/wangqiqi/cursor-ai-rules)
git clone https://github.com/wangqiqi/cursor-ai-rules.git
cd cursor-ai-rules

# 2. Create feature branch
git checkout -b feature/amazing-improvement

# 3. Submit high-quality code
git commit -m "✨ Add amazing AI collaboration feature"

# 4. Create Pull Request
# We'll respond within 24 hours!
```

#### 💡 Non-Code Contributions
- 📝 **Documentation Improvement** - Enhance user guides or add tutorials
- 🐛 **Issue Reporting** - Report bugs or suggest new features
- 💬 **Experience Sharing** - Share usage experiences in Discussions
- 🌍 **Translation Support** - Help translate to other languages
- 🎨 **Design Suggestions** - Propose UI/UX improvements

---

## ❓ Frequently Asked Questions

### 🔰 Getting Started

**Q: Will this affect my existing Cursor settings?**
A: No! The rule system is designed to be non-invasive, only enhancing AI collaboration capabilities.

**Q: Which programming languages are supported?**
A: All mainstream languages! The system auto-detects tech stacks, including JavaScript/TypeScript, Python, Go, Rust, Java, etc.

**Q: Is it paid?**
A: Completely free! Uses MIT license, forever free to use.

### ⚡ Performance Issues

**Q: Will it slow down Cursor's response speed?**
A: No! Intelligent perception runs on-demand, doesn't affect normal editing experience.

**Q: How long does perception analysis take?**
A: First analysis typically completes within 30 seconds, subsequent incremental analyses are faster.

### 🔒 Security & Privacy

**Q: Will my code be uploaded?**
A: No! All analysis is performed locally, no code is uploaded.

**Q: Is Git information collected?**
A: Only reads public Git configuration information for personalized experience.

---

## 📋 Environment Requirements

- **Cursor Editor** v0.40+
- **Git** 2.0+
- **Bash** 4.0+
- **jq** (JSON processor, optional but recommended)

---

## 🎯 Out-of-the-Box Features

### Project Agnostic
- ✅ Auto-detect tech stack (JavaScript, Python, Go, Rust, Java, C/C++, etc.)
- ✅ Smart analysis of team size and development stage
- ✅ Dynamic adaptation to project complexity requirements
- ✅ No hardcoded project-specific information

### User Agnostic
- ✅ Use Git config to get user information
- ✅ Support universal defaults without Git environment
- ✅ Auto-get local time and timezone
- ✅ Privacy protection, no storage of personal sensitive information

### Language Agnostic
- ✅ Auto-detect project file structure
- ✅ Support mainstream programming languages
- ✅ Smart recommendation of language-specific best practices
- ✅ Extensible support for new languages

### Autonomous Perception and Evolution
- ✅ Single-step multi-task project analysis
- ✅ Continuous learning of user collaboration preferences
- ✅ Data-driven rule optimization
- ✅ Progressive system evolution

---

*🚀 Cursor AI Rules v4.2.0 - Intelligent Master leads the new era of AI collaboration*
*Last updated: {{GENERATION_TIME}} | Author: wangqiqi (https://github.com/wangqiqi)*
*Based on Cursor official specifications, integrated with intelligent perception, decision-making and evolution systems*

## 📄 License

This project uses the MIT License - see [LICENSE](LICENSE) file for details
