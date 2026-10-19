" ===============================================================
" 1. 插件列表 (Vim-Plug)
" ===============================================================
call plug#begin('~/.vim/plugged')

" --- 界面美化 ---
Plug 'preservim/nerdtree'           " 左侧文件资源管理器
Plug 'vim-airline/vim-airline'      " 底部状态栏增强
Plug 'catppuccin/vim', { 'as': 'catppuccin' } " 统一配色主题

" --- 代码核心能力 ---
Plug 'neoclide/coc.nvim', {'branch': 'release'} " 补全引擎 (类似 VS Code)
Plug 'Yggdroot/indentLine'          " 缩进对齐线 (看大括号层级神器)
Plug 'jiangmiao/auto-pairs'         " 自动补全括号/引号

call plug#end()

" ===============================================================
" 2. 基础设置 (针对 C 语言优化)
" ===============================================================
set nocompatible      " 关闭 vi 兼容模式
syntax on             " 开启语法高亮
set number            " 显示行号
set cursorline        " 高亮当前行
set wrap              " 自动换行
set showmatch         " 高亮匹配的括号
set mouse=a           " 允许鼠标点击光标和滚轮
set encoding=utf-8
set termguicolors     " 开启真彩色支持

" --- 缩进习惯 (4空格) ---
set tabstop=4
set shiftwidth=4
set expandtab         " 将 Tab 转为空格
set autoindent
set smartindent

" --- 主题设置 (防报错保护) ---
try
    colorscheme catppuccin_mocha
catch
    " 插件没安装前使用默认配色，不报错
endtry

" ===============================================================
" 3. 快捷键映射
" ===============================================================
" <F3> 开关左侧文件树
map <F3> :NERDTreeToggle<CR>

" <F5> 一键保存、编译并运行 C 代码
" 解释: 保存 -> 调用 gcc 编译 -> 如果成功则运行 -> 运行完等待按键
map <F5> :w<CR>:!gcc -Wall -g % -o %< && ./%<<CR>

" 使用 Tab 键进行补全选择 (适配 CoC)
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" --- C语言一键编译运行配置 ---

" 映射 F5 键调用编译运行函数
map <F5> :call CompileRunGcc()<CR>

func! CompileRunGcc()
    exec "w" " 先保存文件
    if &filetype == 'c'
        " 编译命令：gcc 文件名 -o 输出名 -g (开启调试信息) -Wall (显示警告)
        exec "!gcc -Wall -g % -o %<"

        " 检查编译是否成功（在 Linux/Mac 下 && 表示前一条成功才执行下一条）
        if v:shell_error == 0
            " 在下方打开一个新的终端窗口运行程序
            " 如果是 NeoVim，使用 :term ./%<
            " 如果是 Vim 8.1+，使用 :term ./%<
            " 如果不想用内置终端，可以用 !./%<

            " 这里演示使用 Vim 8+ 内置终端运行，体验更好
            :cclose
            :term ./%<
        endif
    endif
endfunc

" --- C语言调试配置 (Termdebug) ---

" 仅在 Vim 版本 > 8.1 时加载
if has('terminal')
    " 加载内置的 termdebug 插件
    packadd termdebug

    " 设置 gdb 程序名 (Mac 用户可能需要改为 'lldb' 或安装的 'gdb')
    let g:termdebug_program = 'gdb'

    " 开启宽屏模式 (源码在左，调试窗口在右，变量在下)
    let g:termdebug_wide = 1
endif

" --- 调试快捷键映射 ---
" F9: 开启/关闭调试器 (自动加载当前编译好的程序)
nnoremap <F9> :Termdebug %<<CR>

" Ctrl+b: 设置断点 (Break)
nnoremap <C-b> :Break<CR>

" F10: 单步跳过 (Next)
nnoremap <F10> :Over<CR>

" F11: 单步进入 (Step)
nnoremap <F11> :Step<CR>

" F12: 继续执行 (Continue)
nnoremap <F12> :Continue<CR>

" 查看变量值: 光标移动到变量上按 K (Vim默认功能，但在Termdebug中会显示值)

" --- coc.nvim 基础配置 ---

" 1. 使用 Tab 键进行补全选择 (非常重要!)
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" 配合函数，如果光标前是空格则输入 Tab，否则启动补全
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" 2. 使用回车选中补全项
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" 3. 常用代码导航快捷键
" gd = Go to Definition (跳转到定义)
nmap <silent> gd <Plug>(coc-definition)
" gy = Go to Type Definition (跳转到类型定义)
nmap <silent> gy <Plug>(coc-type-definition)
" gr = Go to References (查看哪里引用了这个变量/函数)
nmap <silent> gr <Plug>(coc-references)

" 4. 使用 K 键查看光标下函数的文档/参数说明
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" 5. 变量重命名 (比如把全文的 count 改为 total_count)
nmap <leader>rn <Plug>(coc-rename)
