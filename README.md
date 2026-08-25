# claude-5h-statusline

> 极简的 [Claude Code](https://claude.com/claude-code) statusLine 脚本 —— 在命令行底部常驻显示 5h 滚动窗口的**当前用量**和**距重置剩余时间**。

```
5h 42% · 2h13m
```

一眼就能看到额度还剩多少，颜色随用量加深。

## 特点

- **常驻**：任何用量都显示，不必等到逼近上限才发现额度快没了。
- **一眼可读**：`5h <百分比> · <剩余时间>`，百分数按档位着色。
- **零额外依赖**：仅用 **jq**（macOS 自带 `/usr/bin/jq`），无后台进程、不调用任何 API、不需要 API key。
- **数据可信**：直接读取 Claude Code 通过 stdin 传入的官方 `rate_limits.five_hour`，不做估算。

## 显示规则

| 用量 | 百分数颜色 |
|---|---|
| `< 70%` | 薄荷绿 |
| `70% – 89%` | 橙 |
| `≥ 90%` | 红 |

剩余时间（如 `· 2h13m`）恒为暗灰；窗口已重置时显示 `· now`。

分档比较的是**原始值**、显示的是**四舍五入值**，所以 `89.6%` 会显示成 `90%` 但仍是橙色。

Claude Code 尚未下发配额数据时（`rate_limits` 缺失或 `used_percentage` 为 `null`）输出为空 —— 没有数字可显示，不占状态栏。

## 要求

- 已安装 [Claude Code](https://claude.com/claude-code)
- `jq`（macOS 自带；其它系统用包管理器安装）
- `curl`（仅一键安装时需要）

## 安装

一行命令搞定 —— 下载脚本并把 `statusLine` 合并进 `~/.claude/settings.json`（保留已有配置，原文件备份为 `.bak`）：

```bash
curl -fsSL https://raw.githubusercontent.com/mariohide/claude-5h-statusline/main/install.sh | bash
```

下一次启动 Claude Code 即生效（Claude Code 在会话启动时读取 `settings.json`，当前会话不会变）。

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
    "command": "/Users/<you>/.local/bin/claude-5h",
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
    "five_hour": { "used_percentage": 42, "resets_at": 1781609400 }
  }
}
```

`resets_at` 是秒级 Unix 时间戳。脚本只读这两个字段，用一次 `jq` 把百分数与「距重置剩余时长」拼成一行带 ANSI 颜色的文本输出 —— 无需 API key、无需 daemon。

全部数值处理（取整、分档、时长换算）都在 jq 里完成，shell 不碰浮点。

## 自定义

脚本很短，直接改 `claude-5h` 里那段 jq 程序即可：

| 想改的东西 | 位置 |
|---|---|
| 分档阈值（`90` / `70`） | `if $pct >= 90 ... elif $pct >= 70 ...` |
| 分档颜色（薄荷绿 / 橙 / 红） | 同上三个分支里的 truecolor RGB |
| 低用量时重新隐藏 | 在 `($raw \| tonumber) as $pct` 之后加一行 `if $pct < 70 then empty else ... end` |
| 是否显示重置时间 | `$eta` 的计算与末尾的拼接 |
| 时间格式（如 `2h13m`） | `$eta` 里 `$h` / `$m` 的拼接 |

## License

[MIT](LICENSE)
