#!/bin/sh
# Claude Code hook：在 Ghostty 里，等你操作时（请求权限、一轮结束）响一下终端铃。
# Ghostty 收到铃声会在标签页标题前加 🔔、Dock 图标跳一下，切回该标签页后自动消失。
# 不在 Ghostty 里时什么都不做。用法见 README 的 "Claude Code" 一节。

cat >/dev/null                          # 读掉 hook 传入的 JSON，避免管道报错
[ "$TERM_PROGRAM" = ghostty ] || exit 0

# hook 的 stdout 被 Claude Code 接管，所以沿父进程往上找到真正的终端设备
pid=$PPID
while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
  tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
  case $tty in
    ''|'?'|'??') pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ') ;;
    *) [ -w "/dev/$tty" ] && printf '\a' > "/dev/$tty"; exit 0 ;;
  esac
done
exit 0
