# dotfiles

一份可以直接搬到任何 macOS / Linux 机器上的终端配置：zsh、tmux、starship、vim、Ghostty。

- **极简**：单行提示符（路径、git 分支、状态），只用终端自带的 16 色，不需要 Nerd Font。
- **可移植**：所有外部工具都是"装了才用"，一台只有 zsh 和 git 的机器也能正常启动。
- **快**：没有插件管理器，三个插件直接 `source`；提示符只调用 git。

```
~/dotfiles main ! ❯
```

## 安装

```sh
git clone <repo> ~/dotfiles     # 放在哪个目录都行
~/dotfiles/install.sh
exec zsh -l
```

`install.sh` 会建软链接、克隆 zsh 插件，并列出这台机器上缺少的可选工具。
原有的同名文件会挪到 `~/.dotfiles-backup/<时间>/`，不会被覆盖。可以重复执行；
`./install.sh --update` 顺便更新插件。

## 结构

```
zsh/
  zshenv         # 所有 zsh 都读：PATH、EDITOR
  zprofile       # 登录时一次：Homebrew、OrbStack
  zshrc          # 交互：历史、补全、插件、别名、键位、提示符
  functions.zsh  # 自定义函数：mcd / runc / cnew / nvm 懒加载 / conda-init
  local.zsh      # 这台机器私有的别名、函数（git 忽略）
  local.zshenv   # 这台机器私有的 PATH、环境变量（git 忽略）
tmux/tmux.conf   # C-a 前缀、鼠标、vi 复制模式
ghostty/config   # 终端模拟器：主题、字号（Ghostty，macOS / Linux 通用）
starship.toml    # 提示符
.vimrc           # 不装插件也能用；装了 vim-plug 后插件自动生效
install.sh
```

## 外观

提示符、tmux、vim 都只用终端自带的 16 色，所以整体配色只由终端模拟器决定。
用 Ghostty 的话改 `ghostty/config` 里的 `theme` 一行即可（`ghostty +list-themes` 可以带预览地挑）；
用别的终端就在那个终端里换主题，其余部分会自动跟着变。

## 可选工具

| 工具 | 作用 | 没装时 |
| --- | --- | --- |
| starship | 提示符 | 退回到外观相近的纯 zsh 提示符 |
| fzf | Ctrl-R 搜历史、Ctrl-T 找文件、Tab 补全菜单 | 用 zsh 自带补全 |
| zoxide | `z 目录名` 快速跳转 | 没有 `z` |
| eza | `ls` / `ll` / `la` / `lt` | 用系统 `ls` |
| bat | `cat` 带语法高亮 | 用系统 `cat` |
| ripgrep | fzf 找文件时更快 | 用 fzf 默认的查找 |

## Claude Code（可选）

`claude/ghostty-bell.sh` 是一个 Claude Code hook：在 Ghostty 里，Claude Code 请求权限或一轮结束时，
对应标签页标题前会出现 🔔、Dock 图标跳一下，切回该标签页后消失。不在 Ghostty 里时什么都不做。
在 `~/.claude/settings.json` 的 `hooks` 里给 `PermissionRequest` 和 `Stop` 加上：

```json
{ "type": "command", "command": "~/dotfiles/claude/ghostty-bell.sh", "timeout": 5 }
```

## 机器私有配置

只属于某台机器的东西不要写进 `zshrc`：

- 别名、函数、交互相关的写到 `zsh/local.zsh`
- PATH、环境变量、密钥写到 `zsh/local.zshenv`

有些安装器会往 `~/.zshrc` 或 `~/.zshenv` 末尾追加内容，这些文件是指向仓库的软链接，
所以改动会出现在 `git status` 里。把追加的那几行挪到上面两个文件即可。
