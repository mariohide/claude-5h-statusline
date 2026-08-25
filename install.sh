#!/usr/bin/env bash
# claude-5h-statusline 一键安装：
#   curl -fsSL https://raw.githubusercontent.com/mariohide/claude-5h-statusline/main/install.sh | bash
#
# 做三件事：
#   1) 下载 claude-5h 脚本到 ~/.local/bin 并赋可执行权限
#   2) 用 jq 把 statusLine 合并写入 ~/.claude/settings.json（保留已有配置，原文件备份为 .bak）
#   3) 提示生效方式
set -euo pipefail

# 脚本来源（可用 CLAUDE5H_SRC 覆盖，便于本地测试，支持 file:// 与 https://）
SRC="${CLAUDE5H_SRC:-https://raw.githubusercontent.com/mariohide/claude-5h-statusline/main}"
BIN_DIR="$HOME/.local/bin"
DEST="$BIN_DIR/claude-5h"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"

command -v jq >/dev/null 2>&1 || { echo "❌ 需要 jq。macOS 自带 /usr/bin/jq；其它系统用包管理器安装。" >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "❌ 需要 curl。" >&2; exit 1; }

mkdir -p "$BIN_DIR" "$CLAUDE_DIR"

# 1) 下载脚本（rm 先去掉可能存在的软链，避免写穿到别处）
rm -f "$DEST"
curl -fsSL "$SRC/claude-5h" -o "$DEST"
chmod +x "$DEST"

# 2) 合并写入 settings.json（保留已有键，备份 .bak）
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

if [ -f "$SETTINGS" ]; then
  # 先确认是合法 JSON 再动它——原地覆盖一份读不懂的配置等于把它删了
  if ! jq -e . "$SETTINGS" >/dev/null 2>&1; then
    echo "❌ $SETTINGS 不是合法 JSON，已中止（未做任何改动）。请先修好再重跑。" >&2
    exit 1
  fi
  cp "$SETTINGS" "$SETTINGS.bak"
  jq --arg cmd "$DEST" \
    '.statusLine = {type: "command", command: $cmd, refreshInterval: 1}' \
    "$SETTINGS" > "$TMP"
else
  jq -n --arg cmd "$DEST" \
    '{statusLine: {type: "command", command: $cmd, refreshInterval: 1}}' > "$TMP"
fi
mv "$TMP" "$SETTINGS"
trap - EXIT

echo "✅ 已安装：$DEST"
echo "   statusLine 已写入 ${SETTINGS}（原文件备份为 ${SETTINGS}.bak）"
echo "   下一次启动 Claude Code 即生效。"
