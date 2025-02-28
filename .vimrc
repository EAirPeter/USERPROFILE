set nocompatible
filetype off

set hidden

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

if g:os == 'windows'
  set runtimepath+=~/.vim
  let g:coc_config_home='~/.vim'
endif

"""" LargeFile
let s:lf_thresh_no_coc = 1 * 1024 * 1024
let s:lf_thresh_no_filetype = -1
let s:lf_thresh_no_hlsearch = 8 * 1024 * 1024
let s:lf_thresh_no_incsearch = 8 * 1024 * 1024
let s:lf_thresh_no_hlwhitespace = -1
let s:lf_thresh_no_list = -1
let s:lf_thresh_readonly = -1

function! s:LfIsLarge(fsize, thresh)
  return a:thresh >= 0 && (a:fsize == -2 || a:fsize >= a:thresh)
endfunction

function! s:LfBufReadPre(fname)
  let fsize = a:fname->getfsize()
  if s:LfIsLarge(fsize, s:lf_thresh_no_coc)
    let b:coc_enabled = 0
  endif
  if s:LfIsLarge(fsize, s:lf_thresh_no_filetype)
    setl eventignore+=FileType
  endif
  if s:LfIsLarge(fsize, s:lf_thresh_no_hlsearch)
    setl nohlsearch
  endif
  if s:LfIsLarge(fsize, s:lf_thresh_no_incsearch)
    setl noincsearch
  endif
  if s:LfIsLarge(fsize, s:lf_thresh_no_hlwhitespace)
    let b:hl_whitespace = 0
  endif
  if s:LfIsLarge(fsize, s:lf_thresh_no_list)
    setl nolist
  endif
  if s:LfIsLarge(fsize, s:lf_thresh_readonly)
    setl bufhidden=unload
    setl buftype=nowrite
    setl noswapfile
    setl undolevels=-1
  endif
endfunction

augroup RcLargeFile
  au!
  au BufReadPre * call s:LfBufReadPre(expand("<afile>"))
augroup end

"""" Plugins
let g:plugdir = '~/.vim/plugged'

call plug#begin(g:plugdir)

" Appearance
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'EAirPeter/vim-studio-dark'

" COC.NVIM
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" File Types
Plug 'lifepillar/vim-colortemplate'
Plug 'tikhomirov/vim-glsl'
Plug 'beyondmarc/hlsl.vim'
Plug 'pprovost/vim-ps1'
Plug 'lervag/vimtex'
Plug 'shiracamus/vim-syntax-x86-objdump-d'

" Utilities
Plug 'tpope/vim-sleuth'
Plug 'will133/vim-dirdiff'
Plug 'AndrewRadev/linediff.vim'
Plug 'powerman/vim-plugin-AnsiEsc'

call plug#end()

"""" Appearance
filetype plugin on
syntax on

if g:os == 'windows'
  set guifont=Consolas_Nerd_Font_Mono:h12
elseif g:os == 'macosx'
  set guifont=ConsolasNerdFontM-:h12
endif

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

" Powerline Symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.dirty='⚡'

" Syntax Debugging
map <F10> :echo "hi<" .. synIDattr(synID(line("."),col("."),1),"name") .. '> trans<'
  \ .. synIDattr(synID(line("."),col("."),0),"name") .. "> lo<"
  \ .. synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") .. ">"<CR>

" Tab Visualization
set list
set listchars=tab:>-

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
highlight ExtraWhitespace ctermbg=red guibg=red

function! s:HlUpdatePattern(is_ins)
  if w:mid_whitespace
    call matchdelete(w:mid_whitespace)
  endif
  if a:is_ins
    let w:mid_whitespace = matchadd('ExtraWhitespace', '\s\+\%#\@<!$')
  else
    let w:mid_whitespace = matchadd('ExtraWhitespace', '\s\+$')
  endif
endfunction

function! s:HlWinEnter()
  if !exists('b:hl_whitespace')
    let b:hl_whitespace = 1
  endif
  if !exists('w:mid_whitespace')
    let w:mid_whitespace = 0
  endif
  if b:hl_whitespace
    call s:HlUpdatePattern(mode() =~ 'i.*')
    augroup RcHlWhitespace
      au! * <buffer>
      au InsertEnter <buffer> call s:HlUpdatePattern(1)
      au InsertLeave <buffer> call s:HlUpdatePattern(0)
    augroup end
  else
    if w:mid_whitespace
      call matchdelete(w:mid_whitespace)
      let w:mid_whitespace = 0
    endif
    augroup RcHlWhitespace
      au! * <buffer>
    augroup end
  endif
endfunction

augroup RcHighlights
  au!
  au BufWinEnter,WinEnter * call s:HlWinEnter()
augroup end


"""" COC.NVIM

" Extensions
let g:coc_global_extensions = ['coc-clangd',
                            \  'coc-json',
                            \  'coc-pyright',
                            \  'coc-vimlsp']

" Semantic Tokens
let g:coc_default_semantic_highlight_groups = 0

hi link CocSemTypeClass         Type
hi link CocSemTypeComment       Comment
hi link CocSemTypeEnum          Type
hi link CocSemTypeEnumMember    Constant
hi link CocSemTypeMacro         Macro
hi link CocSemTypeNamespace     Type
hi link CocSemTypeTypeParameter Type

" Do not pass message to ins-completion-menu
"set shortmess+=c

" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes

" Use tab/<CR> to accept the completion
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm() : "\<TAB>"
inoremap <silent><expr> <CR>  coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup RcCoc
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

"""" Vimtex
let g:tex_flavor = 'latex'
"let g:vimtex_view_general_viewer = 'SumatraPDF'
"let g:vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
"let g:vimtex_view_general_options_latexmk = '-reuse-instance'

"""" Utilities
nmap <leader>cp :let @+ = expand("%:p")<CR>
nmap <leader>fd :set ff=dos<CR>
nmap <leader>fu :set ff=unix<CR>
nmap <leader>gh :CocCommand clangd.switchSourceHeader<CR>

"""" Compilation and Execution
if g:os == 'windows'
  let s:ce_cc = 'clang -Xclang -flto-visibility-public-std -D_CRT_SECURE_NO_WARNINGS'
  let s:ce_cxx = 'clang++ -Xclang -flto-visibility-public-std -D_CRT_SECURE_NO_WARNINGS'
  let s:ce_include = ['D:\\code\\algo\\include']
  let s:ce_exec = '"%<.exe"'
  let s:ce_clip = 'clip'
elseif g:os == 'wsl'
  let s:ce_cc = 'gcc'
  let s:ce_cxx = 'g++'
  let s:ce_include = ['/mnt/code/algo/include']
  let s:ce_exec = '"./%<.exe"'
  let s:ce_clip = '/mnt/c/Windows/System32/clip.exe'
elseif g:os == 'linux'
  let s:ce_cc = 'gcc'
  let s:ce_cxx = 'g++'
  let s:ce_include = []
  let s:ce_exec = './%<'
  let s:ce_clip = 'xclip'
elseif g:os == 'macosx'
  let s:ce_cc = 'clang'
  let s:ce_cxx = 'clang++'
  let s:ce_include = []
  let s:ce_exec = './%<'
  let s:ce_clip = 'pbcopy'
endif

let s:ce_cflags = '-DVIOLOCAL -Wall -Wconversion -Wextra -Wformat'
for inc in s:ce_include
  let s:ce_cflags ..= ' -I' .. inc
endfor

let s:cpy_c = '!cppcp "%"'
for inc in s:ce_include
  let s:cpy_c ..= ' ' .. inc
endfor
let s:cpy_cpp = s:cpy_c

let s:com_c       = '!' .. s:ce_cc  .. ' -o ' .. s:ce_exec .. ' "%" ' .. s:ce_cflags
let s:com_cpp     = '!' .. s:ce_cxx .. ' -o ' .. s:ce_exec .. ' "%" ' .. s:ce_cflags

let s:arg_c       = ['-std=c99   -O3 -march=native', '-std=c99   -O0 -g -march=native',
                  \  '-std=c11   -O3 -march=native', '-std=c11   -O0 -g -march=native']
let s:arg_cpp     = ['-std=c++14 -O3 -march=native', '-std=c++14 -O0 -g -march=native',
                  \  '-std=c++20 -O3 -march=native', '-std=c++20 -O0 -g -march=native',
                  \  '-std=c++11 -O3 -march=native', '-std=c++11 -O0 -g -march=native',
                  \  '-std=c++98 -O3 -march=native', '-std=c++98 -O0 -g -march=native']

let s:run_c    = '!' .. s:ce_exec
let s:run_cpp  = '!' .. s:ce_exec
let s:dbg_c    = '!gdb ' .. s:ce_exec
let s:dbg_cpp  = '!gdb ' .. s:ce_exec

let s:com_nasm = '!nasm -f bin "%" -o ' .. s:ce_exec .. ' && chmod +x ' .. s:ce_exec
let s:run_nasm = '!' .. s:ce_exec

let s:com_java = '!javac "%"'
let s:run_java = '!java "%<"'

let s:com_rust = '!rustc -o ' .. s:ce_exec .. ' %'
let s:run_rust = '!' .. s:ce_exec

let s:com_tex = '!xelatex "%"'
let s:com_bib = '!bibtex "%"'

if g:os == 'windows'
  let s:run_tex = '!"%<.pdf"'
endif

function! s:CeAppendAll(cmd, args)
  let res = a:cmd
  for arg in a:args
    res ..= ' ' .. arg
  endfor
  return res
endfunction

function! s:CeCompile(idx, ...)
  " F9, C-F9, F7, C-F7, F6, C-F6, F11, C-F11
  let cmd = get(s:, 'com_' .. &filetype, '')
  if cmd == ''
    echo 'No compile command associated with filetype=' .. &filetype
    return
  endif
  let cmd ..= ' ' .. get(s:, 'arg_' .. &filetype, [])->get(a:idx, '')
  execute s:CeAppendAll(cmd, a:000)
endfunction

function! s:CeCopy(...)
  " C-F8
  let cmd = get(s:, 'cpy_' .. &filetype, '')
  if cmd == ''
    let cmd = '!' .. s:ce_clip .. ' < %'
  else
    let cmd = s:CeAppendAll(cmd, a:000) .. ' | ' .. s:ce_clip
  endif
  execute cmd
endfunction

function! s:CeRun(...)
  " F8
  let cmd = get(s:, 'run_' .. &filetype, '')
  if cmd == ''
    echo 'No run command set associated with filetype=' .. &filetype
    return
  endif
  execute s:CeAppendAll(cmd, a:000)
endfunction

function! s:CeDebug(...)
  " F5
  let cmd = get(s:, 'dbg_' .. &filetype, '')
  if cmd == ''
    echo 'No debug command associated with filetype=' .. &filetype
    return
  endif
  execute s:CeAppendAll(cmd, a:000)
endfunction

nnoremap <F5>    :call <SID>CeDebug()<CR>
nnoremap <F8>    :call <SID>CeRun()<CR>
nnoremap <C-F8>  :call <SID>CeCopy()<CR>
nnoremap <F9>    :call <SID>CeCompile(0)<CR>
nnoremap <C-F9>  :call <SID>CeCompile(1)<CR>
nnoremap <F7>    :call <SID>CeCompile(2)<CR>
nnoremap <C-F7>  :call <SID>CeCompile(3)<CR>
nnoremap <F6>    :call <SID>CeCompile(4)<CR>
nnoremap <C-F6>  :call <SID>CeCompile(5)<CR>
nnoremap <F11>   :call <SID>CeCompile(6)<CR>
nnoremap <C-F11> :call <SID>CeCompile(7)<CR>

augroup RcFileTypes
  au!

  au FileType tex       setl spell
  au FileType tex       setl indentexpr=
  au FileType tex       setl tw=99

  "au FileType markdown  setl spell
  au FileType markdown  setl indentexpr=
  au FileType markdown  setl tw=99

  "au FileType text      setl spell
  au FileType text      setl indentexpr=
  au FileType text      setl tw=99

  au FileType c         setl sw=4 sts=4 ts=4
  au FileType cpp       setl sw=4 sts=4 ts=4
  au FileType cs        setl sw=4 sts=4 ts=4
augroup end
