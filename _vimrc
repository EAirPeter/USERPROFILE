set nocompatible
filetype off

set hidden

set pythonthreedll=python37.dll

"""" Operating System
" unknown, windows, wsl, linux, macosx
let g:os = 'unknown'

if has('win64') || has('win32')
  let g:os = 'windows'
elseif has('mac') || has('macunix') || has('osx') || has('osxdarwin')
  let g:os = 'macosx'
elseif has('unix')
  let uname = readfile('/proc/version')
  if uname[0] =~ '[Mm]icrosoft'
    let g:os = 'wsl'
  else
    let g:os = 'linux'
  endif
endif

"""" Plugins
if g:os == 'windows'
  let g:plugdir = '~/vimfiles/plugged'
else
  let g:plugdir = '~/.vim/plugged'
endif

call plug#begin(g:plugdir)

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'EAirPeter/vim-lsp-cxx-highlight'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'EAirPeter/vim-studio-dark'
Plug 'lifepillar/vim-colortemplate'
Plug 'tikhomirov/vim-glsl'
Plug 'pprovost/vim-ps1'
"Plug 'tomasiser/vim-code-dark'
"Plug 'altercation/vim-colors-solarized'

call plug#end()

"""" Color and Themes
filetype plugin on
syntax on

set guifont=Consolas_Nerd_Font_Mono:h12

if (has('termguicolors'))
  set termguicolors
endif

if !exists('g:Vsd')
  let g:Vsd = {}
endif

" High Contrast
let g:Vsd.contrast = 2

set background=dark
colorscheme pole

" Airline
let g:airline_theme = 'violet'

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.dirty='⚡'

map <F10> :echo "hi<" .. synIDattr(synID(line("."),col("."),1),"name") .. '> trans<'
  \ .. synIDattr(synID(line("."),col("."),0),"name") .. "> lo<"
  \ .. synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") .. ">"<CR>

"""" No Useless Files
set nobackup
set nowritebackup
set noundofile

"""" Encodings
set encoding=utf-8
set fileencodings=utf-8,gbk,s-jis

"""" Tabs and Indention
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set smartindent

"""" Misc
set backspace=indent,eol,start
set display=lastline,uhex

set hlsearch
set incsearch

set cmdheight=2
set history=200
set showcmd
set ruler

set number
set colorcolumn=100

set mouse=a

set belloff=all

"set timeout
"set timeoutlen=100

set wildmenu

"""" Highlights

" Highlight long lines.
"highlight LongLine ctermbg=red guibg=red
"au BufWinEnter * let w:m0 = matchadd('LongLine', '\%>80v.\+', -1)

" Highlight trailing spaces.
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+\%#\@<!$/
au InsertLeave * redraw!

"""" Git
augroup VimStartup
  au!
  au BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif
augroup end

"""" COC.NVIM

" Do not pass message to ins-completion-menu
"set shortmess+=c

" The default was 4000 ms.
set updatetime=300

" Sign Column
if has("patch-8.1.1564")
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
"inoremap <silent><expr> <TAB>
"      \ pumvisible() ? "\<C-n>" :
"      \ <SID>check_back_space() ? "\<TAB>" :
"      \ coc#refresh()
"inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
"
"function! s:check_back_space() abort
"  let col = col('.') - 1
"  return !col || getline('.')[col - 1]  =~# '\s'
"endfunction

inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

"""" Compilation and Execution
if g:os == 'windows'
  let s:ce_cc = 'clang -Xclang -flto-visibility-public-std -D_CRT_SECURE_NO_WARNINGS'
  let s:ce_cxx = 'clang++ -Xclang -flto-visibility-public-std -D_CRT_SECURE_NO_WARNINGS'
  let s:ce_include = ['D:\\code\\algo\\include']
  let s:ce_exec = '%<.exe'
  let s:ce_clip = 'clip'
elseif g:os == 'wsl'
  let s:ce_cc = 'gcc'
  let s:ce_cxx = 'g++'
  let s:ce_include = ['/mnt/code/algo/include']
  let s:ce_exec = './%<.exe'
  let s:ce_clip = '/mnt/c/Windows/System32/clip.exe'
elseif g:os == 'linux'
  let s:ce_cc = 'gcc'
  let s:ce_cxx = 'g++'
  let s:ce_include = []
  let s:ce_exec = './%<'
  let s:ce_clip = 'xclip'
endif

let s:ce_cflags = '-DVIOLOCAL -Wall -Wconversion -Wextra -Wformat'
for inc in s:ce_include
  let s:ce_cflags ..= ' -I' .. inc
endfor

let s:cpy_c = '!cppcp %'
for inc in s:ce_include
  let s:cpy_c ..= ' ' .. inc
endfor
let s:cpy_cpp = s:cpy_c

let s:com_c       = '!' .. s:ce_cc  .. ' -o ' .. s:ce_exec .. ' % ' .. s:ce_cflags
let s:com_cpp     = '!' .. s:ce_cxx .. ' -o ' .. s:ce_exec .. ' % ' .. s:ce_cflags

let s:arg_c       = ['-std=c99   -O2', '-std=c99   -O0 -g',
                  \  '-std=c11   -O2', '-std=c11   -O0 -g']
let s:arg_cpp     = ['-std=c++14 -O2', '-std=c++14 -O0 -g',
                  \  '-std=c++17 -O2', '-std=c++17 -O0 -g',
                  \  '-std=c++11 -O2', '-std=c++11 -O0 -g',
                  \  '-std=c++98 -O2', '-std=c++98 -O0 -g']

let s:run_c    = '!' .. s:ce_exec
let s:run_cpp  = '!' .. s:ce_exec
let s:dbg_c    = '!gdb ' .. s:ce_exec
let s:dbg_cpp  = '!gdb ' .. s:ce_exec

let s:com_java = '!javac %'
let s:run_java = '!java %<'

let s:com_rust = '!rustc -o ' .. s:ce_exec .. ' %'
let s:run_rust = '!' .. s:ce_exec

let s:com_tex = '!xelatex %'
let s:com_bib = '!bibtex %'

function! CeAppendAll(cmd, args)
  let res = a:cmd
  for arg in a:args
    res ..= ' ' .. arg
  endfor
  return res
endfunction

function! CeCompile(idx, ...)
  " F9, C-F9, F7, C-F7, F6, C-F6, F11, C-F11
  let cmd = get(s:, 'com_' .. &filetype, '')
  if cmd == ''
    echo 'No compile command associated with filetype=' .. &filetype
    return
  endif
  let cmd ..= ' ' .. get(s:, 'arg_' .. &filetype, [])->get(a:idx, '')
  execute CeAppendAll(cmd, a:000)
endfunction

function! CeCopy(...)
  " C-F8
  let cmd = get(s:, 'cpy_' .. &filetype, '')
  if cmd == ''
    let cmd = '!' .. s:ce_clip .. ' < %'
  else
    let cmd = CeAppendAll(cmd, a:000) .. ' | ' .. s:ce_clip
  endif
  execute cmd
endfunction

function! CeRun(...)
  " F8
  let cmd = get(s:, 'run_' .. &filetype, '')
  if cmd == ''
    echo 'No run command set associated with filetype=' .. &filetype
    return
  endif
  execute CeAppendAll(cmd, a:000)
endfunction

function! CeDebug(...)
  " F5
  let cmd = get(s:, 'dbg_' .. &filetype, '')
  if cmd == ''
    echo 'No debug command associated with filetype=' .. &filetype
    return
  endif
  execute CeAppendAll(cmd, a:000)
endfunction

nnoremap <F5>    :call CeDebug()<CR>
nnoremap <F8>    :call CeRun()<CR>
nnoremap <C-F8>  :call CeCopy()<CR>
nnoremap <F9>    :call CeCompile(0)<CR>
nnoremap <C-F9>  :call CeCompile(1)<CR>
nnoremap <F7>    :call CeCompile(2)<CR>
nnoremap <C-F7>  :call CeCompile(3)<CR>
nnoremap <F6>    :call CeCompile(4)<CR>
nnoremap <C-F6>  :call CeCompile(5)<CR>
nnoremap <F11>   :call CeCompile(6)<CR>
nnoremap <C-F11> :call CeCompile(7)<CR>

au FileType tex       setlocal spell
au FileType tex       setlocal indentexpr=
au FileType tex       setlocal tw=99

au FileType markdown  setlocal spell
au FileType markdown  setlocal indentexpr=
au FileType markdown  setlocal tw=99

au FileType text      setlocal spell
au FileType text      setlocal indentexpr=
au FileType text      setlocal tw=99
