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

# --- codex 走固定本地代理入口 ---
codex() {
  local codex_proxy_url="http://127.0.0.1:17890"

  if ! /usr/bin/nc -z -w 2 127.0.0.1 17890 >/dev/null 2>&1; then
    echo "固定本地代理入口 127.0.0.1:17890 不可用"
    return 1
  fi

  env \
    HTTP_PROXY="$codex_proxy_url" \
    HTTPS_PROXY="$codex_proxy_url" \
    ALL_PROXY="$codex_proxy_url" \
    NO_PROXY="localhost,127.0.0.1,::1" \
    http_proxy="$codex_proxy_url" \
    https_proxy="$codex_proxy_url" \
    all_proxy="$codex_proxy_url" \
    no_proxy="localhost,127.0.0.1,::1" \
    "$HOME/.local/bin/codex-math" "$@"
}

# --- ZJU Connect LaunchAgent 管理 ---
[[ -f "$HOME/.config/zju-connect/functions.zsh" ]] && source "$HOME/.config/zju-connect/functions.zsh"
