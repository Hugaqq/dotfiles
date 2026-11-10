" vimrc — 不装任何插件也能正常使用；装了 vim-plug 后插件作为增强自动生效。
" 配色跟随终端主题，不依赖真彩色和特殊字体。

" ===============================================================
" 1. 基础设置
" ===============================================================
set nocompatible
filetype plugin indent on
syntax on
set encoding=utf-8
set number            " 行号
set wrap
set showmatch         " 高亮匹配的括号
set mouse=a
set hidden            " 未保存也能切换 buffer
set incsearch hlsearch ignorecase smartcase
set wildmenu
set backspace=indent,eol,start
set ttimeoutlen=10    " Esc 不卡顿
set laststatus=2
set statusline=\ %f\ %m%r%=%y\ \ %l:%c\ \ %p%%

" 只高亮当前行的行号，不整行铺底色
if exists('+cursorlineopt')
  set cursorline cursorlineopt=number
endif

" 缩进：4 空格
set tabstop=4 shiftwidth=4 expandtab autoindent smartindent

" 配色：用终端自带的 16 色，终端换主题它跟着变
set background=dark
silent! colorscheme default

" ===============================================================
" 2. 插件（可选）
"    安装 vim-plug 后执行 :PlugInstall：
"    curl -fLo ~/.vim/autoload/plug.vim --create-dirs
"         https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" ===============================================================
if filereadable(expand('~/.vim/autoload/plug.vim'))
  call plug#begin('~/.vim/plugged')
  Plug 'preservim/nerdtree'           " 文件树
  Plug 'jiangmiao/auto-pairs'         " 自动补全括号/引号
  if executable('node')
    Plug 'neoclide/coc.nvim', {'branch': 'release'}   " 补全引擎，需要 Node
  endif
  call plug#end()
endif

" 插件已声明且已下载到本地才算可用
function! s:has_plugin(name) abort
  return exists('g:plugs') && has_key(g:plugs, a:name) && isdirectory(g:plugs[a:name].dir)
endfunction

" ===============================================================
" 3. 快捷键
" ===============================================================
" <F3> 文件树：有 NERDTree 用 NERDTree，没有就用内置的 netrw
if s:has_plugin('nerdtree')
  nnoremap <F3> :NERDTreeToggle<CR>
else
  let g:netrw_banner = 0
  let g:netrw_winsize = 25
  nnoremap <F3> :Lexplore<CR>
endif

" <F5> 保存、编译并运行当前 C 文件
nnoremap <F5> :call CompileRunC()<CR>
function! CompileRunC() abort
  write
  if &filetype !=# 'c'
    echo '只支持 C 文件'
    return
  endif
  execute '!cc -Wall -g % -o %<'
  if v:shell_error == 0
    if has('terminal')
      cclose
      terminal ./%<
    else
      execute '!./%<'
    endif
  endif
endfunction

" 调试（内置 Termdebug）：F9 启动，Ctrl-b 断点，F10 跳过，F11 进入，F12 继续
if has('terminal')
  packadd termdebug
  let g:termdebug_wide = 1
  " macOS 上通常没有 gdb，需要的话在这里改成自己装的调试器
  let g:termdebug_program = 'gdb'
  nnoremap <F9>  :Termdebug %<<CR>
  nnoremap <C-b> :Break<CR>
  nnoremap <F10> :Over<CR>
  nnoremap <F11> :Step<CR>
  nnoremap <F12> :Continue<CR>
endif

" ===============================================================
" 4. coc.nvim（装了才启用）
" ===============================================================
if s:has_plugin('coc.nvim')
  function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~# '\s'
  endfunction

  " Tab / Shift-Tab 选择补全项，回车确认
  inoremap <silent><expr> <TAB>
        \ coc#pum#visible() ? coc#pum#next(1) :
        \ CheckBackspace() ? "\<Tab>" :
        \ coc#refresh()
  inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
  inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

  " gd 定义 / gy 类型定义 / gr 引用 / K 文档 / <leader>rn 重命名
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gr <Plug>(coc-references)
  nmap <leader>rn <Plug>(coc-rename)
  nnoremap <silent> K :call ShowDocumentation()<CR>
  function! ShowDocumentation() abort
    if CocAction('hasProvider', 'hover')
      call CocActionAsync('doHover')
    else
      call feedkeys('K', 'in')
    endif
  endfunction
endif
