# dotfiles

终端与编辑器的单一配置源。home 目录下的文件都是指向这里的软链接。

## 结构

```
zsh/
  zshenv        # 所有 zsh 都读：PATH、EDITOR、BAT_THEME
  zprofile      # 登录时一次：brew shellenv、国内镜像、OrbStack
  zshrc         # 交互：历史、补全、插件、别名、键位、提示符
  functions.zsh # 自定义函数：mcd / runc / nvm 懒加载 / codex / zju
  local.zsh     # 机器私有配置（git 忽略）
tmux/tmux.conf  # tmux：C-a 前缀、鼠标、真彩色、Catppuccin 状态栏
starship.toml   # 提示符
.zsh_plugins.txt # antidote 插件清单
.vimrc
```

## 软链接

```
~/.zshenv                    -> ~/dotfiles/zsh/zshenv
~/.zprofile                  -> ~/dotfiles/zsh/zprofile
~/.zshrc                     -> ~/dotfiles/zsh/zshrc
~/.tmux.conf                 -> ~/dotfiles/tmux/tmux.conf
~/.config/starship.toml      -> ~/dotfiles/starship.toml
~/.config/scripts/myfunc.sh  -> ~/dotfiles/zsh/functions.zsh
~/.zsh_plugins.txt           -> ~/dotfiles/.zsh_plugins.txt
```

## 新机器上安装

```sh
git clone <repo> ~/dotfiles
ln -s dotfiles/zsh/zshenv ~/.zshenv
ln -s dotfiles/zsh/zprofile ~/.zprofile
ln -s dotfiles/zsh/zshrc ~/.zshrc
ln -s dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -s ../dotfiles/starship.toml ~/.config/starship.toml
ln -s dotfiles/.zsh_plugins.txt ~/.zsh_plugins.txt
exec zsh -l
```
