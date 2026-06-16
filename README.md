# claude-5h-statusline

> 极简的 [Claude Code](https://claude.com/claude-code) statusLine 脚本 —— 只在 5h 用量逼近上限时，于命令行底部安静地显示**当前用量**和**距重置剩余时间**。

```
5h 70% · 2h13m
```

平时不打扰；当 5h 滚动窗口用量 ≥ 70% 时才出现，颜色随用量加深，让你对剩余额度心里有数。

## 特点

- **安静**：用量 < 70% 时完全隐藏，不占用状态栏。
- **一眼可读**：`5h <百分比> · <剩余时间>`，百分数按档位着色。
- **零额外依赖**：仅用 **Node**（Claude Code 自带），无后台进程、不调用任何 API、不需要 API key。
- **数据可信**：直接读取 Claude Code 通过 stdin 传入的官方 `rate_limits.five_hour`，不做估算。

## 显示规则

| 用量 | 表现 |
|---|---|
| `< 70%` | 隐藏 |
| `70% – 89%` | 橙色百分数 |
| `≥ 90%` | 红色百分数 |

剩余时间（如 `· 2h13m`）恒为暗灰；窗口已重置时显示 `· now`。

## 要求

- 已安装 [Claude Code](https://claude.com/claude-code)
- `node`（随 Claude Code 提供）
- `curl`（仅一键安装时需要）

## 安装

一行命令搞定 —— 下载脚本并把 `statusLine` 合并进 `~/.claude/settings.json`（保留已有配置，原文件备份为 `.bak`）：

```bash
curl -fsSL https://raw.githubusercontent.com/mariohide/claude-5h-statusline/main/install.sh | bash
```

下一次在 Claude Code 发消息即生效（Claude Code 在会话启动时读取 `settings.json`）。

<details>
<summary>手动安装</summary>

```bash
# 1. 放到 PATH 上并赋可执行权限
install -m 0755 claude-5h ~/.local/bin/claude-5h
```

```jsonc
// 2. 在 ~/.claude/settings.json 里配置 statusLine（command 用绝对路径）
{
  "statusLine": {
    "type": "command",
    "command": "/home/<you>/.local/bin/claude-5h",
    "refreshInterval": 1
  }
}
```

</details>

## 更新

重新跑一次一键安装命令即可覆盖到最新版（旧 `settings.json` 会再次备份）：

```bash
curl -fsSL https://raw.githubusercontent.com/mariohide/claude-5h-statusline/main/install.sh | bash
```

## 卸载

```bash
rm -f ~/.local/bin/claude-5h
# 然后从 ~/.claude/settings.json 删除 "statusLine" 块
# （安装时的备份在 ~/.claude/settings.json.bak）
```

## 原理

Claude Code 渲染 statusLine 时，会把一份 JSON 通过 **stdin** 传给配置的命令，其中包含 5h 滚动窗口的用量：

```json
{
  "rate_limits": {
    "five_hour": { "used_percentage": 70, "resets_at": 1781609400 }
  }
}
```

`resets_at` 是秒级 Unix 时间戳。脚本只读这两个字段，把百分数与「距重置剩余时长」拼成一行带 ANSI 颜色的文本输出 —— 无需 API key、无需 daemon。

## 自定义

脚本很短，直接改 `claude-5h` 即可：

| 想改的东西 | 位置 |
|---|---|
| 显示阈值（默认 `< 70` 隐藏） | `main()` 里的 `if (pct < 70) return` |
| 分档颜色（薄荷绿 / 橙 / 红） | `colorFor()` 的三个 truecolor RGB |
| 是否显示重置时间 | `fmtReset()` 及其拼接处 |
| 时间格式（如 `2h13m`） | `fmtReset()` |

## License

[MIT](LICENSE)
