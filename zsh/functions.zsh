# ~/dotfiles/zsh/functions.zsh — 自定义函数（由 ~/.zshrc 加载）

# --- 创建目录并进入 ---
mcd() { mkdir -p "$1" && cd "$1"; }

# --- 编译并运行单个 C 文件 ---
runc() { gcc -Wall -g "$1" -o "${1%.*}" && ./"${1%.*}" }

# --- 生成汇编 ---
checkasm() {
  gcc -S -O0 -fverbose-asm "$1" -o "${1%.*}.s"
  echo "Assembly generated at ${1%.*}.s"
}

# --- nvm 懒加载：首次调用 nvm 时才加载，省掉每次开 shell 的 0.2s ---
nvm() {
  unfunction nvm
  export NVM_DIR="$HOME/.nvm"
  [[ -s /opt/homebrew/opt/nvm/nvm.sh ]] && source /opt/homebrew/opt/nvm/nvm.sh
  nvm "$@"
}

# --- conda 按需初始化（当前未使用，需要时执行 conda-init） ---
conda-init() {
  local conda_sh=/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh
  if [[ ! -f $conda_sh ]]; then
    echo "找不到 $conda_sh"
    return 1
  fi
  source "$conda_sh"
  conda activate "${1:-base}"
}

# --- codex：跟随系统代理（与桌面 App 一致），可用 CODEX_PROXY 覆盖 ---
codex() {
  local proxy="${CODEX_PROXY:-}"

  if [[ -z $proxy ]]; then
    proxy=$(scutil --proxy 2>/dev/null | awk -F' *: *' '
      /HTTPSEnable/ { en = $2 }
      /HTTPSProxy/  { host = $2 }
      /HTTPSPort/   { port = $2 }
      END { if (en == 1 && host != "" && port != "") print host ":" port }')
  fi

  if [[ -n $proxy ]]; then
    env \
      HTTP_PROXY="http://$proxy" \
      HTTPS_PROXY="http://$proxy" \
      ALL_PROXY="http://$proxy" \
      NO_PROXY="localhost,127.0.0.1,::1" \
      http_proxy="http://$proxy" \
      https_proxy="http://$proxy" \
      all_proxy="http://$proxy" \
      no_proxy="localhost,127.0.0.1,::1" \
      "$HOME/.local/bin/codex-math" "$@"
  else
    "$HOME/.local/bin/codex-math" "$@"
  fi
}

# --- ZJU Connect LaunchAgent 管理 ---
[[ -f "$HOME/.config/zju-connect/functions.zsh" ]] && source "$HOME/.config/zju-connect/functions.zsh"
