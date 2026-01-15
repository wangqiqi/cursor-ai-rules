---
command: platform_adapter
description: "跨平台适配器 - 统一管理不同操作系统间的命令、路径和环境适配"
alwaysApply: true
---

# 🌐 跨平台适配器 (Cross-platform Adapter)

*版本: v4.2.0 | 最后更新: {{GENERATION_TIME}} | 作者: wangqiqi (https://github.com/wangqiqi)*

## 🎯 核心使命 (Core Mission)

跨平台适配器统一管理.cursor规则体系在不同操作系统间的适配逻辑，确保：

- **命令兼容性**：自动选择适合当前平台的命令和参数
- **路径规范化**：统一处理不同操作系统的路径格式
- **环境适配**：根据操作系统特征调整行为和配置
- **错误处理**：平台特定的错误信息和恢复策略

## 🔍 平台检测 (Platform Detection)

### 操作系统识别 (OS Identification)
```bash
# 自动检测当前操作系统
detect_platform() {
    case "$(uname -s)" in
        Linux*)     PLATFORM="linux";;
        Darwin*)    PLATFORM="macos";;
        CYGWIN*|MINGW*|MSYS*) PLATFORM="windows";;
        *)          PLATFORM="unknown";;
    esac

    # Windows特殊处理：检测是否在WSL环境中
    if [[ "$PLATFORM" == "linux" ]] && [[ -n "$WSL_DISTRO_NAME" ]]; then
        PLATFORM="wsl"
    fi

    echo "$PLATFORM"
}
```

### 平台特征矩阵 (Platform Feature Matrix)
```json
{
  "platform_features": {
    "linux": {
      "shell": "bash",
      "path_separator": "/",
      "case_sensitive": true,
      "permissions": "unix",
      "package_manager": ["apt", "yum", "dnf", "pacman"],
      "line_ending": "LF"
    },
    "macos": {
      "shell": "zsh",
      "path_separator": "/",
      "case_sensitive": false,
      "permissions": "unix",
      "package_manager": ["brew", "port"],
      "line_ending": "LF"
    },
    "windows": {
      "shell": "powershell",
      "path_separator": "\\",
      "case_sensitive": false,
      "permissions": "windows",
      "package_manager": ["choco", "winget", "scoop"],
      "line_ending": "CRLF"
    },
    "wsl": {
      "shell": "bash",
      "path_separator": "/",
      "case_sensitive": true,
      "permissions": "unix",
      "package_manager": ["apt"],
      "line_ending": "LF",
      "special_features": ["windows_integration"]
    }
  }
}
```

## 💻 命令适配 (Command Adaptation)

### 核心命令映射 (Core Command Mapping)
```typescript
interface CommandMapping {
  [command: string]: {
    linux: string;
    macos: string;
    windows: string;
    wsl?: string;
  };
}

const commandMappings: CommandMapping = {
  "get_timestamp": {
    linux: "date '+%Y-%m-%d %H:%M:%S %Z'",
    macos: "date '+%Y-%m-%d %H:%M:%S %Z'",
    windows: "powershell -Command \"Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'\"",
    wsl: "date '+%Y-%m-%d %H:%M:%S %Z'"
  },
  "get_user_name": {
    linux: "git config --get user.name",
    macos: "git config --get user.name",
    windows: "git config --get user.name",
    wsl: "git config --get user.name"
  },
  "get_user_email": {
    linux: "git config --get user.email",
    macos: "git config --get user.email",
    windows: "git config --get user.email",
    wsl: "git config --get user.email"
  },
  "list_directory": {
    linux: "ls -la",
    macos: "ls -la",
    windows: "powershell -Command \"Get-ChildItem -Force\"",
    wsl: "ls -la"
  },
  "create_directory": {
    linux: "mkdir -p",
    macos: "mkdir -p",
    windows: "powershell -Command \"New-Item -ItemType Directory -Force\"",
    wsl: "mkdir -p"
  }
};
```

### 动态命令执行 (Dynamic Command Execution)
```typescript
class CommandExecutor {
  private platform: string;

  constructor(platform: string) {
    this.platform = platform;
  }

  async execute(commandName: string, params: string[] = []): Promise<CommandResult> {
    const mapping = commandMappings[commandName];
    if (!mapping) {
      throw new Error(`Unknown command: ${commandName}`);
    }

    const command = this.buildCommand(mapping, params);
    return this.runCommand(command);
  }

  private buildCommand(mapping: any, params: string[]): string {
    let command = mapping[this.platform] || mapping.linux; // fallback to linux

    // 替换参数占位符
    params.forEach((param, index) => {
      command = command.replace(`{${index}}`, this.escapeParameter(param));
    });

    return command;
  }

  private escapeParameter(param: string): string {
    // 根据平台进行参数转义
    switch (this.platform) {
      case 'windows':
        return param.replace(/"/g, '""'); // PowerShell转义
      default:
        return param.replace(/'/g, "'\\''"); // Bash转义
    }
  }
}
```

## 📁 路径处理 (Path Handling)

### 路径规范化 (Path Normalization)
```typescript
class PathNormalizer {
  private platform: string;

  constructor(platform: string) {
    this.platform = platform;
  }

  normalize(path: string): string {
    // 统一路径分隔符
    const normalized = path.replace(/[/\\]+/g, this.getSeparator());

    // 处理特殊路径
    return this.handleSpecialPaths(normalized);
  }

  private getSeparator(): string {
    return this.platform === 'windows' ? '\\' : '/';
  }

  private handleSpecialPaths(path: string): string {
    const replacements = {
      '~': this.getHomeDirectory(),
      '$HOME': this.getHomeDirectory(),
      '%USERPROFILE%': this.getHomeDirectory(),
      '/c/': 'C:\\',  // WSL路径转换
    };

    for (const [pattern, replacement] of Object.entries(replacements)) {
      if (path.includes(pattern)) {
        path = path.replace(pattern, replacement);
      }
    }

    return path;
  }

  private getHomeDirectory(): string {
    switch (this.platform) {
      case 'linux':
      case 'macos':
      case 'wsl':
        return process.env.HOME || '/home/user';
      case 'windows':
        return process.env.USERPROFILE || 'C:\\Users\\User';
      default:
        return '/home/user';
    }
  }
}
```

### 路径操作 (Path Operations)
```json
{
  "path_operations": {
    "join": {
      "description": "路径拼接",
      "linux": "path1/path2",
      "windows": "path1\\path2",
      "implementation": "path.join() or custom logic"
    },
    "resolve": {
      "description": "路径解析（相对转绝对）",
      "linux": "realpath",
      "windows": "powershell Resolve-Path",
      "implementation": "path.resolve() or platform-specific commands"
    },
    "relative": {
      "description": "计算相对路径",
      "linux": "realpath --relative-to",
      "windows": "powershell custom logic",
      "implementation": "path.relative() or platform-specific calculation"
    }
  }
}
```

## 🔧 环境适配 (Environment Adaptation)

### 环境变量处理 (Environment Variables)
```typescript
class EnvironmentAdapter {
  private platform: string;

  constructor(platform: string) {
    this.platform = platform;
  }

  getEnvironmentVariable(name: string): string | undefined {
    // 跨平台环境变量获取
    const envMappings = {
      'HOME': {
        linux: 'HOME',
        macos: 'HOME',
        windows: 'USERPROFILE',
        wsl: 'HOME'
      },
      'TEMP': {
        linux: 'TMPDIR',
        macos: 'TMPDIR',
        windows: 'TEMP',
        wsl: 'TMPDIR'
      }
    };

    const mappedName = envMappings[name]?.[this.platform] || name;
    return process.env[mappedName];
  }

  setEnvironmentVariable(name: string, value: string): void {
    // 跨平台环境变量设置
    const command = this.buildSetEnvCommand(name, value);
    this.executeCommand(command);
  }

  private buildSetEnvCommand(name: string, value: string): string {
    switch (this.platform) {
      case 'windows':
        return `powershell -Command "[Environment]::SetEnvironmentVariable('${name}', '${value}', 'User')"`;
      default:
        return `export ${name}="${value}"`;
    }
  }
}
```

### 权限和安全 (Permissions and Security)
```json
{
  "permission_handling": {
    "file_permissions": {
      "linux": {
        "read": "chmod +r",
        "write": "chmod +w",
        "execute": "chmod +x"
      },
      "windows": {
        "read": "icacls /grant user:R",
        "write": "icacls /grant user:W",
        "execute": "icacls /grant user:X"
      }
    },
    "administrator_privileges": {
      "linux": "sudo",
      "macos": "sudo",
      "windows": "runas /user:administrator",
      "wsl": "sudo"
    }
  }
}
```

## 🚨 错误处理适配 (Error Handling Adaptation)

### 平台特定错误 (Platform-specific Errors)
```typescript
class ErrorAdapter {
  private platform: string;

  constructor(platform: string) {
    this.platform = platform;
  }

  translateError(error: Error): LocalizedError {
    const errorMappings = {
      'ENOENT': {
        linux: '文件或目录不存在',
        windows: '文件或目录不存在',
        english: 'No such file or directory'
      },
      'EACCES': {
        linux: '权限不足',
        windows: '访问被拒绝',
        english: 'Permission denied'
      },
      'ENOTEMPTY': {
        linux: '目录不为空',
        windows: '目录不为空',
        english: 'Directory not empty'
      }
    };

    const mapping = errorMappings[error.code];
    if (mapping) {
      return {
        original: error,
        localized: mapping[this.platform] || mapping.english,
        suggestions: this.getErrorSuggestions(error.code)
      };
    }

    return {
      original: error,
      localized: error.message,
      suggestions: []
    };
  }

  private getErrorSuggestions(errorCode: string): string[] {
    const suggestions = {
      'ENOENT': [
        '检查文件路径是否正确',
        '确认文件是否存在',
        '检查工作目录'
      ],
      'EACCES': [
        '检查文件权限',
        '尝试以管理员身份运行',
        '检查文件是否被其他程序占用'
      ]
    };

    return suggestions[errorCode] || [];
  }
}
```

### 恢复策略 (Recovery Strategies)
```json
{
  "recovery_strategies": {
    "command_failure": {
      "retry": {
        "max_attempts": 3,
        "delay_ms": 1000,
        "backoff_multiplier": 2
      },
      "fallback_commands": {
        "linux": ["alternative_command", "generic_fallback"],
        "windows": ["powershell_equivalent", "generic_fallback"]
      }
    },
    "network_issues": {
      "timeout_adjustment": {
        "linux": "timeout 30s command",
        "windows": "powershell timeout logic"
      },
      "proxy_handling": {
        "auto_detect_proxy": true,
        "proxy_env_vars": ["HTTP_PROXY", "HTTPS_PROXY"]
      }
    }
  }
}
```

## 📊 适配器集成 (Adapter Integration)

### 统一接口 (Unified Interface)
```typescript
interface PlatformAdapter {
  // 平台检测
  getPlatform(): string;
  getPlatformFeatures(): PlatformFeatures;

  // 命令执行
  executeCommand(commandName: string, params?: any[]): Promise<CommandResult>;

  // 路径处理
  normalizePath(path: string): string;
  joinPaths(...paths: string[]): string;

  // 环境适配
  getEnvironmentVariable(name: string): string | undefined;
  setEnvironmentVariable(name: string, value: string): void;

  // 错误处理
  translateError(error: Error): LocalizedError;
  getRecoveryStrategy(error: Error): RecoveryStrategy;
}
```

### 工厂模式 (Factory Pattern)
```typescript
class PlatformAdapterFactory {
  static create(): PlatformAdapter {
    const platform = this.detectPlatform();

    switch (platform) {
      case 'linux':
        return new LinuxAdapter();
      case 'macos':
        return new MacOSAdapter();
      case 'windows':
        return new WindowsAdapter();
      case 'wsl':
        return new WSLAdapter();
      default:
        return new GenericAdapter();
    }
  }

  private static detectPlatform(): string {
    // 平台检测逻辑
    return detect_platform();
  }
}
```

### 缓存和优化 (Caching and Optimization)
```json
{
  "adapter_optimization": {
    "command_caching": {
      "enabled": true,
      "ttl_seconds": 300,
      "max_cache_size": 100
    },
    "path_resolution_caching": {
      "enabled": true,
      "ttl_seconds": 600,
      "max_cache_size": 50
    },
    "platform_detection_caching": {
      "enabled": true,
      "ttl_seconds": 3600,
      "invalidate_on_restart": true
    }
  }
}
```

---

*跨平台适配器为.cursor规则体系提供统一的平台抽象层，确保在不同操作系统间的一致性和可靠性。*
