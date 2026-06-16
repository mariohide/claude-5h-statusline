# claude-5h-statusline

极简的 [Claude Code](https://claude.com/claude-code) statusLine 脚本，只在 5h 用量窗口达到阈值后，于命令行底部显示**当前用量百分比**和**距重置剩余时间**。

```
5h 70% · 2h13m
```

- 仅在用量 **≥ 70%** 时显示，平时保持安静
- 百分数按档位着色：**< 90% 橙 / ≥ 90% 红**（阈值内置薄荷绿用于更低用量，可改）
- 重置剩余时间为暗灰
- 仅依赖 **Node**（Claude Code 自带，无需额外安装）、无后台进程、不调用任何 API —— 直接读取 Claude Code 通过 stdin 传入的 `rate_limits.five_hour`

## 原理

Claude Code 在渲染 statusLine 时，会把一份 JSON 通过 **stdin** 传给命令，其中包含：

```json
{
  "rate_limits": {
    "five_hour": { "used_percentage": 70, "resets_at": 1781609400 }
  }
}
```

`resets_at` 是秒级 Unix 时间戳。脚本只读这两个字段，无需 API key、无需 daemon。

## 安装

```bash
# 1. 放到 PATH 上并赋可执行权限
install -m 0755 claude-5h ~/.local/bin/claude-5h

# 2. 在 ~/.claude/settings.json 里配置 statusLine
```

```json
{
  "statusLine": {
    "type": "command",
    "command": "/home/<you>/.local/bin/claude-5h",
    "refreshInterval": 1
  }
}
```

下一次发消息时生效（Claude Code 在会话启动时读取 `settings.json`）。

## 自定义

脚本很短，直接改即可：

| 想改的东西 | 位置 |
|---|---|
| 显示阈值（默认 `< 70` 隐藏） | `main()` 里的 `if (pct < 70) return` |
| 分档颜色（薄荷绿 / 橙 / 红） | `colorFor()` 的三个 truecolor RGB |
| 是否显示重置时间 | `fmtReset()` 及其拼接处 |
| 时间格式（如 `2h13m`） | `fmtReset()` |

## License

MIT
