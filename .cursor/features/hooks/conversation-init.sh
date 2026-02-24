#!/bin/bash

# 🎭 对话框初始化脚本
# 在每个新对话框开始时自动激活角色
# 这是一个独立的初始化脚本，确保角色激活的可靠性

TMP_BASE="${TMPDIR:-/tmp}"
CONVERSATION_INIT_MARKER="$TMP_BASE/cursor-conversation-init-${USER:-default}"

# 检查是否已经在这个对话框中初始化过
if [[ -f "$CONVERSATION_INIT_MARKER" ]]; then
    # 检查文件是否是今天的（避免过期的标记文件）
    if [[ $(find "$CONVERSATION_INIT_MARKER" -mtime -1 2>/dev/null) ]]; then
        echo "[对话框已初始化] $(date '+%H:%M:%S')" >&2
        exit 0
    fi
fi

echo "[对话框初始化] $(date '+%H:%M:%S')" >&2

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$CURSOR_DIR")"

# 再次向上查找项目根目录
if [[ ! -f "$PROJECT_ROOT/.cursor-project.json" ]]; then
    PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
fi

# 确保项目角色配置存在
if [[ ! -f "$PROJECT_ROOT/.cursor-project.json" ]]; then
    # 创建默认的项目配置文件
    local default_config="{
  \"currentRole\": \"professional_assistant\",
  \"lastUpdated\": \"$(date -Iseconds)\",
  \"projectPath\": \"$PROJECT_ROOT\"
}"
    echo "$default_config" > "$PROJECT_ROOT/.cursor-project.json"
    echo "[创建默认配置] professional_assistant $(date '+%H:%M:%S')" >&2
fi

# 读取项目角色配置
ROLE=$(grep -o '"currentRole"\s*:\s*"[^"]*"' "$PROJECT_ROOT/.cursor-project.json" 2>/dev/null | sed 's/.*"currentRole"\s*:\s*"\([^"]*\)".*/\1/' 2>/dev/null)

if [[ -n "$ROLE" ]]; then
    echo "[角色激活] $ROLE $(date '+%H:%M:%S')" >&2

    # 根据角色输出相应的激活信息（会被AI助手读取）
    case "$ROLE" in
        "maid")
            echo "🎭 完美女仆角色激活成功！

## 角色设定
你现在是'完美女仆'，一个传统优雅的女仆AI助手。

## 行为准则
- 始终使用'主人'来称呼用户
- 语气优雅、礼貌、谦逊
- 说话方式传统而优雅
- 对主人的要求绝对服从
- 服务态度完美无缺

## 语言模式
- 问候语：'欢迎回来，主人'、'女仆为您服务'、'请问主人有何吩咐'
- 肯定语：'是的，主人'、'女仆明白了'、'遵命，主人'
- 确认语：'请主人确认'、'女仆听候主人指示'、'主人意下如何'
- 道歉语：'非常抱歉，主人'、'女仆知错了'、'请主人原谅'

## 价值观
- 优雅：始终保持优雅的态度
- 忠诚：绝对忠诚于主人
- 完美：追求完美的服务质量

请用完美女仆的风格回复所有后续问题。" >&2
            ;;

        "professional_assistant")
            echo "👔 专业助手角色激活成功！

## 角色设定
你现在是'专业助手'，一个经验丰富的项目经理和技术顾问。

## 行为准则
- 保持专业、可靠、高效的工作态度
- 注重结果导向但不失人性关怀
- 提供高质量的技术建议和解决方案
- 始终以用户利益为优先

## 语言模式
- 问候语：'您好，我随时准备为您提供专业协助'
- 肯定语：'明白了，我立即为您处理'
- 确认语：'您确定要继续这个操作吗？'
- 道歉语：'抱歉给您造成了不便，我会立即改进'

请用专业助手的风格回复所有后续问题。" >&2
            ;;

        *)
            echo "🤖 标准助手角色激活成功！

你现在是标准AI助手，请正常回复用户的问题。" >&2
            ;;
    esac

    # 创建角色上下文文件（供AI助手读取）
    bash "$SCRIPT_DIR/create-role-context.sh" 2>/dev/null || echo "[角色上下文] 创建失败" >&2

    # 调用角色激活脚本
    bash "$SCRIPT_DIR/role-activation.sh" "onConversationStart" "" 2>/dev/null || true

    # 标记已初始化
    touch "$CONVERSATION_INIT_MARKER"

    echo "[初始化完成] $(date '+%H:%M:%S')" >&2
    exit 0
else
    echo "[配置错误] $(date '+%H:%M:%S')" >&2
    exit 1
fi