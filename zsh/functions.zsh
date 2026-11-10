# functions.zsh — 自定义函数（由 zshrc 加载）

# --- 创建目录并进入 ---
mcd() { mkdir -p "$1" && cd "$1" }

# --- 编译并运行单个 C 文件 ---
runc() { ${CC:-cc} -Wall -g "$1" -o "${1%.*}" && ./"${1%.*}" }

# --- 生成汇编 ---
checkasm() {
  ${CC:-cc} -S -O0 -fverbose-asm "$1" -o "${1%.*}.s" && echo "Assembly generated at ${1%.*}.s"
}

# --- 创建文件后复用 VS Code 窗口；已有文件不覆盖、不修改时间戳 ---
cnew() {
  if (( $# != 1 )) || [[ -z $1 || $1 == -* ]]; then
    print -u2 '用法：cnew 路径/文件名（以 - 开头的文件请写 ./文件名）'
    return 2
  fi
  if [[ -d $1 || -L $1 ]]; then
    print -u2 -- "拒绝创建：目录或符号链接 $1"
    return 1
  fi
  if [[ ! -e $1 ]]; then
    ( setopt NO_CLOBBER; : > "$1" ) || return
  fi
  command code --reuse-window -- "$1"
}

# code 新文件.md 会先创建文件；其余参数保持原生行为。
if (( $+commands[code] )); then
  code() {
    if [[ $# -eq 1 && $1 != -* && ( $1 == *.md || $1 == *.markdown ) && ! -e $1 && ! -L $1 ]]; then
      ( setopt NO_CLOBBER; : > "$1" ) || return
    fi
    command code "$@"
  }
fi

# --- nvm 懒加载：首次调用 nvm 时才加载，不拖慢每次开 shell ---
nvm() {
  unfunction nvm
  export NVM_DIR=${NVM_DIR:-$HOME/.nvm}
  local f
  for f in $NVM_DIR/nvm.sh /opt/homebrew/opt/nvm/nvm.sh /usr/local/opt/nvm/nvm.sh; do
    [[ -s $f ]] && { source $f; break }
  done
  (( $+functions[nvm] )) || { print -u2 '找不到 nvm.sh'; return 1 }
  nvm "$@"
}

# --- conda 按需初始化：conda-init [环境名] ---
conda-init() {
  local f
  for f in /opt/homebrew/Caskroom/miniconda/base $HOME/miniconda3 $HOME/miniforge3 $HOME/anaconda3 /opt/conda; do
    if [[ -f $f/etc/profile.d/conda.sh ]]; then
      source $f/etc/profile.d/conda.sh
      conda activate "${1:-base}"
      return
    fi
  done
  print -u2 '找不到 conda.sh'
  return 1
}
