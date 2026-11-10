#!/usr/bin/env bash
# 安装 dotfiles：建软链接 + 克隆 zsh 插件。可重复执行，macOS / Linux 通用。
#   ./install.sh            安装
#   ./install.sh --update   顺便把插件更新到最新
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
PLUGINS="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
UPDATE=0
[ "${1:-}" = "--update" ] && UPDATE=1

# link <仓库内路径> <home 下路径>：已指向仓库则跳过；原有文件先挪到备份目录
link() {
  local src="$DOTFILES/$1" dst="$HOME/$2"
  if [ -L "$dst" ] && [ "$dst" -ef "$src" ]; then
    echo "  已链接  ~/$2"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP/$(dirname "$2")"
    mv "$dst" "$BACKUP/$2"
    echo "  已备份  ~/$2 -> $BACKUP/$2"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "  新链接  ~/$2"
}

# plugin <github 用户/仓库>
plugin() {
  local dir="$PLUGINS/${1##*/}"
  if [ -d "$dir/.git" ]; then
    if [ "$UPDATE" = 1 ]; then
      git -C "$dir" pull -q --ff-only && echo "  已更新  $1" || echo "  更新失败  $1"
    else
      echo "  已存在  $1"
    fi
  else
    git clone -q --depth=1 "https://github.com/$1" "$dir" && echo "  已克隆  $1" \
      || echo "  克隆失败  $1（不影响使用，之后重跑 install.sh 即可）"
  fi
}

echo "软链接："
link zsh/zshenv     .zshenv
link zsh/zprofile   .zprofile
link zsh/zshrc      .zshrc
link tmux/tmux.conf .tmux.conf
link .vimrc         .vimrc
link ghostty/config .config/ghostty/config

echo "zsh 插件："
if command -v git >/dev/null; then
  mkdir -p "$PLUGINS"
  plugin zsh-users/zsh-autosuggestions
  plugin zsh-users/zsh-syntax-highlighting
  plugin Aloxaf/fzf-tab
else
  echo "  没有 git，跳过"
fi

# 机器私有文件：没有就建一个空模板（不进 git）
for f in local.zsh local.zshenv; do
  if [ ! -e "$DOTFILES/zsh/$f" ]; then
    echo "# $f — 这台机器私有的配置，不提交到 git" > "$DOTFILES/zsh/$f"
  fi
done

echo "可选工具（没装也能用，装了体验更好）："
missing=""
for t in zsh starship fzf zoxide eza bat rg tmux; do
  if command -v "$t" >/dev/null || { [ "$t" = bat ] && command -v batcat >/dev/null; }; then
    echo "  有  $t"
  else
    echo "  缺  $t"
    missing="$missing $t"
  fi
done
if [ -n "$missing" ]; then
  pkgs="${missing/ rg/ ripgrep}"
  echo
  if command -v brew >/dev/null; then
    echo "安装缺少的工具：brew install$pkgs"
  elif command -v apt-get >/dev/null; then
    echo "安装缺少的工具：sudo apt install$pkgs"
    echo "（apt 里没有的，比如 starship：curl -sS https://starship.rs/install.sh | sh）"
  else
    echo "请用系统的包管理器安装:$pkgs"
  fi
fi

case "${SHELL:-}" in
  */zsh) ;;
  *) command -v zsh >/dev/null && echo && echo "默认 shell 还不是 zsh：chsh -s $(command -v zsh)" ;;
esac

echo
echo "完成。重开终端，或执行：exec zsh -l"
