# 脚本目录需求分析结果

生成时间: 2026年 01月 18日 星期日 13:50:54 CST

## 📋 发现的脚本文件

- `.cursor/core/adaptive-optimization-engine.sh`
- `.cursor/core/agent-orchestration-engine.sh`
- `.cursor/core/architecture-compliance-checker.sh`
- `.cursor/core/batch-executor.sh`
- `.cursor/core/common.sh`
- `.cursor/core/compact-output.sh`
- `.cursor/core/config-manager.sh`
- `.cursor/core/config-validator.sh`
- `.cursor/core/consistency-checker.sh`
- `.cursor/core/context-manager.sh`
- `.cursor/core/context-pool-manager.sh`
- `.cursor/core/continuous-learning-loop.sh`
- `.cursor/core/continuous-learning-loop-simple.sh`
- `.cursor/core/conversational-command-system.sh`
- `.cursor/core/cursor-sync.sh`
- `.cursor/core/demo-project-isolation.sh`
- `.cursor/core/dependency-checker.sh`
- `.cursor/core/env-perception.sh`
- `.cursor/core/experiment-framework.sh`
- `.cursor/core/git-commit.sh`
- `.cursor/core/growth-manager.sh`
- `.cursor/core/growth-recorder.sh`
- `.cursor/core/init.sh`
- `.cursor/core/isolation-debugger.sh`
- `.cursor/core/local-mcp-integration.sh`
- `.cursor/core/logging.sh`
- `.cursor/core/mcp-detector.sh`
- `.cursor/core/optimizer.sh`
- `.cursor/core/path-config.sh`
- `.cursor/core/pattern-analyzer.sh`
- `.cursor/core/perception-enhancer.sh`
- `.cursor/core/performance-cache.sh`
- `.cursor/core/performance-dashboard.sh`
- `.cursor/core/performance-monitor.sh`
- `.cursor/core/quality-manager.sh`
- `.cursor/core/quality-reporter.sh`
- `.cursor/core/self-learning-engine.sh`
- `.cursor/core/test-cache-functionality.sh`
- `.cursor/core/token-compression.sh`
- `.cursor/core/validate-growth-paths.sh`
- `.cursor/core/vibe-alignment-checker.sh`
- `.cursor/core/vibe-services-integration.sh`
- `.cursor/features/automation/scripts/convert_to_agent_skills.sh`
- `.cursor/features/automation/scripts/growth_init.sh`
- `.cursor/features/automation/scripts/plugin_manager.sh`
- `.cursor/features/hooks/architecture-check.sh`
- `.cursor/features/hooks/code-quality.sh`
- `.cursor/features/hooks/command-log.sh`
- `.cursor/features/hooks/config-validator.sh`
- `.cursor/features/hooks/consistency-check.sh`
- `.cursor/features/hooks/cursor-sync.sh`
- `.cursor/features/hooks/dependency-check.sh`
- `.cursor/features/hooks/env-perception.sh`
- `.cursor/features/hooks/event-logger.sh`
- `.cursor/features/hooks/growth-recorder.sh`
- `.cursor/features/hooks/master-init.sh`
- `.cursor/features/hooks/performance-monitor.sh`
- `.cursor/features/hooks/prompt-security.sh`
- `.cursor/features/hooks/quality-check.sh`
- `.cursor/features/hooks/rule-usage-tracker.sh`
- `.cursor/features/hooks/security-audit.sh`
- `.cursor/features/hooks/session-optimizer.sh`
- `.cursor/features/hooks/session-summary.sh`
- `.cursor/features/hooks/test-hooks.sh`
- `.cursor/features/hooks/token-compression.sh`
- `.cursor/features/skills/converter.sh`
- `.cursor/features/skills/discovery.sh`

## 📁 目录创建分析

### mkdir 命令使用情况:

- 包含 mkdir 命令的脚本数量: 85

### 详细的 mkdir 使用:

- **.cursor/features/automation/scripts/plugin_manager.sh**: `    mkdir -p "$PLUGIN_ROOT"`
- **.cursor/features/automation/scripts/convert_to_agent_skills.sh**: `mkdir -p "$SKILLS_DIR"`
- **.cursor/features/automation/scripts/convert_to_agent_skills.sh**: `    mkdir -p "$target_dir"`
- **.cursor/features/automation/scripts/growth_init.sh**: `mkdir -p .cursor/features/hooks/command-log.sh:if [[ "$command" =~ ^(ls|pwd|cd|mkdir|touch) ]]; then`
- **.cursor/features/hooks/command-log.sh**: `mkdir -p "$CURSOR_GROWTH/logs"`
- **.cursor/features/hooks/command-log.sh**: `    mkdir -p "$ANALYTICS_DIR"`
- **.cursor/features/hooks/command-log.sh**: `    mkdir -p "$ANALYTICS_DIR"`
- **.cursor/features/hooks/rule-usage-tracker.sh**: `mkdir -p "$ANALYTICS_DIR"`
- **.cursor/features/hooks/session-summary.sh**: `mkdir -p "$ANALYTICS_DIR"`
- **.cursor/features/hooks/security-audit.sh**: `    mkdir -p "$ANALYTICS_DIR"`
- **.cursor/features/hooks/security-audit.sh**: `mkdir -p "$CURSOR_GROWTH/logs"`
- **.cursor/features/hooks/master-init.sh**: `                mkdir -p "$GROWTH_DIR"/{learning,conversations,growth,personal,cache,monitoring,debug,logs,sync,mcps,compression}`
- **.cursor/features/hooks/master-init.sh**: `            mkdir -p "$GROWTH_DIR"/{learning,conversations,growth,personal,cache,monitoring,debug,logs,sync,mcps,compression}`
- **.cursor/features/hooks/master-init.sh**: `        mkdir -p "$GROWTH_DIR/learning"`
- **.cursor/features/hooks/master-init.sh**: `        mkdir -p "$GROWTH_DIR/monitoring"`
- **.cursor/features/hooks/prompt-security.sh**: `mkdir -p "$ANALYTICS_DIR"`
- **.cursor/features/hooks/code-quality.sh**: `mkdir -p "$ANALYTICS_DIR"`
- **.cursor/core/growth-manager.sh**: `        mkdir -p "$GROWTH_DIR/$dir"`
- **.cursor/core/growth-manager.sh**: `            mkdir -p "$GROWTH_DIR/$dir"`
- **.cursor/core/growth-manager.sh**: `        mkdir -p "$GROWTH_DIR/mcps/user-pdf-reader"`
- **.cursor/core/context-manager.sh**: `    mkdir -p "$CONTEXT_CACHE_DIR"`
- **.cursor/core/context-manager.sh**: `    mkdir -p "$AI_DIR"  # 创建AI目录`
- **.cursor/core/context-manager.sh**: `    mkdir -p "$CONFIG_DATA_DIR"`
- **.cursor/core/pattern-analyzer.sh**: `    mkdir -p "$ANALYSIS_DIR"`
- **.cursor/core/context-pool-manager.sh**: `    mkdir -p "$CONTEXT_POOL_DIR"`
- **.cursor/core/context-pool-manager.sh**: `    mkdir -p "$session_dir"`
- **.cursor/core/token-compression.sh**: `    mkdir -p "$CONFIG_DATA_DIR"`
- **.cursor/core/architecture-compliance-checker.sh**: `    if grep -q ">s*.cursor/|echo.*>.*.cursor/|cat.*>.*.cursor/|mkdir.*.cursor/" "$file" 2>/dev/null; then`
- **.cursor/core/architecture-compliance-checker.sh**: `    if grep -q ">s*.cursor/|echo.*>.*.cursor/|cat.*>.*.cursor/|mkdir.*.cursor/" "$file" 2>/dev/null; then`
- **.cursor/core/architecture-compliance-checker.sh**: `    mkdir -p "$ANALYTICS_DIR"`
- **.cursor/core/agent-orchestration-engine.sh**: `    mkdir -p "$AGENT_CONFIG_DIR"`
- **.cursor/core/performance-monitor.sh**: `    mkdir -p "$ANALYTICS_DATA_DIR" "$ANALYTICS_CACHE_DIR"`
- **.cursor/core/continuous-learning-loop-simple.sh**: `    mkdir -p "$CONTINUOUS_LEARNING_DIR"`
- **.cursor/core/continuous-learning-loop-simple.sh**: `    mkdir -p "$LEARNING_BUFFER_DIR"`
- **.cursor/core/continuous-learning-loop-simple.sh**: `    mkdir -p "$MODEL_CHECKPOINTS_DIR"`
- **.cursor/core/continuous-learning-loop-simple.sh**: `    mkdir -p "$LEARNING_METRICS_DIR"`
- **.cursor/core/growth-recorder.sh**: `        mkdir -p "$GROWTH_DIR/learning" "$GROWTH_DIR/conversations" "$GROWTH_DIR/growth"`
- **.cursor/core/init.sh**: `    mkdir -p "$SCRIPT_DIR/../core"`
- **.cursor/core/init.sh**: `    mkdir -p "$SCRIPT_DIR/../features"`
- **.cursor/core/init.sh**: `    mkdir -p "$SCRIPT_DIR/../config"`
- **.cursor/core/init.sh**: `    mkdir -p "$SCRIPT_DIR/../quality"`
- **.cursor/core/init.sh**: `    mkdir -p "$SCRIPT_DIR/../docs"`
- **.cursor/core/init.sh**: `    mkdir -p "$SCRIPT_DIR/../features/automation"`
- **.cursor/core/init.sh**: `    mkdir -p "$SCRIPT_DIR/../features/skills"`
- **.cursor/core/init.sh**: `    mkdir -p "$SCRIPT_DIR/../features/hooks"`
- **.cursor/core/init.sh**: `    mkdir -p "$SCRIPT_DIR/../features/plugins"`
- **.cursor/core/init.sh**: `    mkdir -p "$HOME/.cursor/config"`
- **.cursor/core/self-learning-engine.sh**: `    mkdir -p "$LEARNING_MODELS_DIR"`
- **.cursor/core/self-learning-engine.sh**: `    mkdir -p "$LEARNING_TRAINING_DIR" "$LEARNING_RESULTS_DIR"`
- **.cursor/core/self-learning-engine.sh**: `    mkdir -p "$LEARNING_METRICS_DIR"`
- **.cursor/core/config-manager.sh**: `    mkdir -p "$(dirname "$config_path")"`
- **.cursor/core/experiment-framework.sh**: `    mkdir -p "$EXPERIMENT_DIR"`
- **.cursor/core/path-config.sh**: `            mkdir -p "$PROJECT_ROOT/.cursorGrowth"`
- **.cursor/core/path-config.sh**: `        mkdir -p "$CURSOR_GROWTH"`
- **.cursor/core/path-config.sh**: `            mkdir -p "$full_path"`
- **.cursor/core/path-config.sh**: `    mkdir -p "$CURSOR_GROWTH"`
- **.cursor/core/conversational-command-system.sh**: `    mkdir -p "$VIBE_COMMAND_DIR"`
- **.cursor/core/conversational-command-system.sh**: `    mkdir -p "$VIBE_SESSIONS_DIR"`
- **.cursor/core/conversational-command-system.sh**: `    mkdir -p "$VIBE_PROJECTS_DIR"`
- **.cursor/core/conversational-command-system.sh**: `    mkdir -p "$project_dir"`
- **.cursor/core/conversational-command-system.sh**: `    mkdir -p "$session_dir"`
- **.cursor/core/conversational-command-system.sh**: `        mkdir -p "$phase_dir"`
- **.cursor/core/conversational-command-system.sh**: `    mkdir -p "$project_dir/artifacts"`
- **.cursor/core/performance-dashboard.sh**: `    mkdir -p "$DASHBOARD_DIR"`
- **.cursor/core/adaptive-optimization-engine.sh**: `    mkdir -p "$OPTIMIZATION_DIR"`
- **.cursor/core/common.sh**: `    mkdir -p "$config_dir" 2>/dev/null || handle_error "无法创建配置目录: $config_dir" "common"`
- **.cursor/core/vibe-alignment-checker.sh**: `        mkdir -p "$GROWTH_DIR"`
- **.cursor/core/vibe-alignment-checker.sh**: `    mkdir -p "$ALIGNMENT_CHECKS_DIR"`
- **.cursor/core/vibe-alignment-checker.sh**: `    mkdir -p "$REPORTS_DIR"`
- **.cursor/core/vibe-alignment-checker.sh**: `    mkdir -p "${ALIGNMENT_CHECKS_DIR}/contracts"`
- **.cursor/core/vibe-alignment-checker.sh**: `    mkdir -p "${ALIGNMENT_CHECKS_DIR}/snapshots"`
- **.cursor/core/local-mcp-integration.sh**: `    mkdir -p "$MCP_INTEGRATION_DIR"`
- **.cursor/core/local-mcp-integration.sh**: `    mkdir -p "$server_dir"`
- **.cursor/core/cursor-sync.sh**: `    mkdir -p "$GROWTH_DIR/sync"`
- **.cursor/core/cursor-sync.sh**: `    mkdir -p "$target_dir"`
- **.cursor/core/cursor-sync.sh**: `    mkdir -p "$target_dir"`
- **.cursor/core/cursor-sync.sh**: `                mkdir -p "$target_resources"`
- **.cursor/core/continuous-learning-loop.sh**: `    mkdir -p "$CONTINUOUS_LEARNING_DIR"`
- **.cursor/core/isolation-debugger.sh**: `    mkdir -p "$BACKUP_DIR"`
- **.cursor/core/performance-cache.sh**: `    mkdir -p "$CACHE_DIR"`
- **.cursor/core/logging.sh**: `    mkdir -p "$LOG_DIR" 2>/dev/null || true`
- **.cursor/core/vibe-services-integration.sh**: `    mkdir -p "$VIBE_SERVICES_DIR"`
- **.cursor/core/vibe-services-integration.sh**: `    mkdir -p "$persistence_dir"`
- **.cursor/core/vibe-services-integration.sh**: `    mkdir -p "$tracker_dir/dependencies"`

## 📄 文件操作分析

### 文件写入操作 (echo >, cat >):

- 文件写入操作数量: 504

- **.cursor/features/automation/scripts/plugin_manager.sh**: `    echo "用法: $0 <命令> [参数]"...`
- **.cursor/features/automation/scripts/plugin_manager.sh**: `    echo "  enable <插件名>         启用指定插件"...`
- **.cursor/features/automation/scripts/plugin_manager.sh**: `    echo "  disable <插件名>        禁用指定插件"...`
- **.cursor/features/automation/scripts/plugin_manager.sh**: `    echo "  install <Git URL>       从Git仓库安装插件"...`
- **.cursor/features/automation/scripts/plugin_manager.sh**: `    echo "  uninstall <插件名>      卸载指定插件"...`
- **.cursor/features/automation/scripts/plugin_manager.sh**: `    echo "  update <插件名>         更新指定插件"...`
- **.cursor/features/automation/scripts/growth_init.sh**: `    echo "⚠️  路径配置加载失败，尝试手动设置..." >&2...`
- **.cursor/features/automation/scripts/growth_init.sh**: `    echo "📁 使用手动设置的路径: $CURSOR_GROWTH" >&2...`
- **.cursor/features/hooks/command-log.sh**: `echo "$log_entry" >> $CURSOR_GROWTH/logs/command-execution.log...`
- **.cursor/features/hooks/command-log.sh**: `    echo "[$timestamp] SLOW_COMMAND: $command took ${duration}ms" >> $CURSOR_GROWTH/logs/performance...`
- **.cursor/features/hooks/command-log.sh**: `    echo "[$timestamp] COMMAND_ERROR: $command" >> $CURSOR_GROWTH/logs/command-errors.log...`
- **.cursor/features/hooks/command-log.sh**: `    echo "Error output: $output" >> $CURSOR_GROWTH/logs/command-errors.log...`
- **.cursor/features/hooks/rule-usage-tracker.sh**: `    echo "$log_entry" >> $CURSOR_GROWTH/logs/rule-usage.log...`
- **.cursor/features/hooks/rule-usage-tracker.sh**: `    echo "📋 检测到规则使用: $rules_used" >> $CURSOR_GROWTH/logs/rule-usage.log...`
- **.cursor/features/hooks/rule-usage-tracker.sh**: `    echo "$log_entry" >> $CURSOR_GROWTH/logs/rule-usage.log...`
- **.cursor/features/hooks/rule-usage-tracker.sh**: `echo "$quality_metrics" >> $CURSOR_GROWTH/logs/response-quality.log...`
- **.cursor/features/hooks/rule-usage-tracker.sh**: `    echo "$timestamp|$conversation_id|PATTERN:security_focus" >> $CURSOR_GROWTH/logs/rule-patterns.l...`
- **.cursor/features/hooks/rule-usage-tracker.sh**: `    echo "$timestamp|$conversation_id|PATTERN:context_awareness" >> $CURSOR_GROWTH/logs/rule-pattern...`
- **.cursor/features/hooks/rule-usage-tracker.sh**: `    echo "$timestamp|$conversation_id|PATTERN:configuration_generation" >> $CURSOR_GROWTH/logs/rule-...`
- **.cursor/features/hooks/rule-usage-tracker.sh**: `    echo "📈 生成使用统计摘要..." >> $CURSOR_GROWTH/logs/rule-usage.log...`

### 文件读取操作 (cat, source, <):

- 文件读取操作数量: 667

- **.cursor/features/skills/converter.sh**: `    local content=$(cat "$skill_md")...`
- **.cursor/features/skills/converter.sh**: `    cat > "$output_file" << EOF...`
- **.cursor/features/automation/scripts/plugin_manager.sh**: `    echo "用法: $0 <命令> [参数]"...`
- **.cursor/features/automation/scripts/plugin_manager.sh**: `    echo "  enable <插件名>         启用指定插件"...`
- **.cursor/features/automation/scripts/plugin_manager.sh**: `    echo "  disable <插件名>        禁用指定插件"...`
- **.cursor/features/automation/scripts/plugin_manager.sh**: `    echo "  install <Git URL>       从Git仓库安装插件"...`
- **.cursor/features/automation/scripts/plugin_manager.sh**: `    echo "  uninstall <插件名>      卸载指定插件"...`
- **.cursor/features/automation/scripts/plugin_manager.sh**: `    echo "  update <插件名>         更新指定插件"...`
- **.cursor/features/automation/scripts/convert_to_agent_skills.sh**: `    local source_file="$EXTENSIONS_DIR/${skill_name}.md"...`
- **.cursor/features/automation/scripts/convert_to_agent_skills.sh**: `    if [ ! -f "$source_file" ]; then...`
- **.cursor/features/automation/scripts/convert_to_agent_skills.sh**: `    local content=$(cat "$source_file")...`
- **.cursor/features/automation/scripts/convert_to_agent_skills.sh**: `    cat > "$target_file" << EOF...`
- **.cursor/features/automation/scripts/growth_init.sh**: `    cat > "$GROWTH_DIR/growth_meta.json" << EOF...`
- **.cursor/features/automation/scripts/growth_init.sh**: `    "communication_patterns": {},...`
- **.cursor/features/automation/scripts/growth_init.sh**: `    cat > "$GROWTH_DIR/learning/preferences.json" << EOF...`

## 🎯 路径使用模式分析

### 硬编码路径使用:

- 硬编码路径引用数量: 157

### 旧变量使用情况:

- 旧路径变量引用数量: 173

- GROWTH_DIR: 107 处使用
- AI_DIR: 18 处使用
- ANALYTICS_DIR: 24 处使用
- CACHE_DIR: 24 处使用
- LOGS_DIR: 4 处使用

## 📊 统计摘要

- **总脚本数量**: 0
- **使用 mkdir 的脚本**: 85
- **硬编码路径引用**: 157
- **旧变量引用**: 173

