" |-----------------------------------------------------------------------------------|
" |                                                                                   |
" | Mappings                                                                          |
" |-----------------------------------------------------------------------------------|
" | コマンド        | ノーマル | 挿入 | コマンドライン | ビジュアル | 選択 | 演算待ち |
" | map  / noremap  |    @     |  -   |       -        |     @      |  @   |    @     |
" | map! / noremap! |    -     |  @   |       @        |     -      |  -   |    -     |
" | nmap / nnoremap |    @     |  -   |       -        |     -      |  -   |    -     |
" | imap / inoremap |    -     |  @   |       -        |     -      |  -   |    -     |
" | cmap / cnoremap |    -     |  -   |       @        |     -      |  -   |    -     |
" | vmap / vnoremap |    -     |  -   |       -        |     @      |  @   |    -     |
" | xmap / xnoremap |    -     |  -   |       -        |     @      |  -   |    -     |
" | smap / snoremap |    -     |  -   |       -        |     -      |  @   |    -     |
" | omap / onoremap |    -     |  -   |       -        |     -      |  -   |    @     |
" |-----------------------------------------------------------------------------------|

scriptencoding utf-8

set encoding=utf-8
set fileencodings=utf-8
set fileformats=unix,dos,mac


let g:loaded_perl_provider = 0

" lang en_US.UTF-8

filetype off
filetype plugin indent off

"----------------------
" packer
"----------------------
if has('win32')
  let s:packer_repo_dir = expand('~/AppData/Local/nvim-data/site/pack/packer/start/packer.nvim')
else
  let s:packer_repo_dir = expand('~/.local/share/nvim/site/pack/packer/start/packer.nvim')
endif
" packerが入っていなければinstall
if !isdirectory(s:packer_repo_dir)
  call system('git clone https://github.com/wbthomason/packer.nvim ' . shellescape(s:packer_repo_dir))
endif

lua << EOF
require'plugins'
EOF

augroup packer
  autocmd!
  autocmd BufWritePost */lua/plugins.lua PackerCompile
  autocmd BufWritePost */lua/plugins/*.lua PackerCompile

  " PackerInstall
  " PackerSync

  " autocmd BufWritePost */lua/plugins.lua echo 'update plugins.lua'
  " autocmd BufWritePost */lua/plugins/*.lua echo 'update plugins/*.lua'

augroup End

"----------------------
"dein
"----------------------
if has('win32')
  let s:dein_dir = expand('~/AppData/Local/nvim.bundle')
else
  let s:dein_dir = expand('~/.config/nvim.bundle')
endif

let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim' " dein.vim 本体
let g:dein#install_process_timeout =  600

" deinが入っていなければinstall
if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif

" 設定開始
let &runtimepath = s:dein_repo_dir .",". &runtimepath
if has('win32')
  let s:toml = '~/AppData/Local/nvim/dein.toml'
else
  let s:toml = '~/.config/nvim/dein.toml'
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir, [$MYVIMRC, s:toml])

  call dein#load_toml(s:toml, {'lazy': 0})

  call dein#end()
  call dein#save_state()
endif

" もし、未インストールものがあったらインストール
" すると、めちゃ重い
if dein#check_install()
  call dein#install()
endif

" こいつら、重い
" call dein#update()
" call dein#recache_runtimepath()

"-------------------
" plugin
"-------------------
let g:did_install_default_menus = 1
let g:did_install_syntax_menu   = 1
let g:did_indent_on             = 1
let g:loaded_2html_plugin       = 1
let g:loaded_gzip               = 1
let g:loaded_man                = 1
" let g:loaded_matchit            = 1
let g:loaded_matchparen         = 1
let g:loaded_netrwPlugin        = 1
let g:loaded_remote_plugins     = 1
let g:loaded_shada_plugin       = 1
let g:loaded_spellfile_plugin   = 1
let g:loaded_tarPlugin          = 1
let g:loaded_tutor_mode_plugin  = 1
let g:loaded_zipPlugin          = 1
let g:skip_loading_mswin        = 1

" packadd matchit
" source $VIMRUNTIME/macros/matchit.vim
" runtime macros/matchit.vim

"-------------------
" keymap
"-------------------
noremap <Leader> <Nop>
let mapleader = "\<Space>"
nmap <Leader><Leader> <Space>

"esc2回でハイライトを消す
nnoremap <silent> <ESC><ESC> :noh<cr>

noremap <silent> j gj
noremap <silent> k gk
noremap <silent> gj j
noremap <silent> gk k

noremap gf gF
noremap gF gf

"挿入モード便利キー
" noremap <C-P> <Up>
" noremap <C-N> <Down>

" cnoremap <C-P> <Up>
" cnoremap <C-N> <Down>
noremap! <C-F> <Right>
noremap! <C-B> <Left>
noremap! <C-[> <ESC>

" jump時カーソルを中心にする
nnoremap <C-O> <C-O>zz
nnoremap <C-I> <C-I>zz

" この行がないと<C-c>のマッピングが効かない
nnoremap <C-c> <Nop>


"command line windowを表示
"swap semicolon and colon
" noremap : ;
" noremap ; :
" set cedit=\<C-f>

" 検索時語句を中心にする
nnoremap * *zz
nnoremap n nzz
nnoremap N Nzz

" exモードを無効に
nnoremap Q <Nop>

" macの辞書を開く
nnoremap g? :!open dict://<cword><CR>

" " clipboardにコピーする
" vnoremap Y "+y
" vnoremap D "+d

"fold
nnoremap zl zo
nnoremap zL zO
nnoremap zh zc
nnoremap zH zC

nnoremap gf gF

" ----------------------------------------
" <m> commands
" マーク関連
" ----------------------------------------
" 基本マップ
" nnoremap [Mark] <Nop>
" nmap m [Mark]
nnoremap <silent>gm :<C-u>call <SID>AutoMarkrement()<CR>

" 次/前のマーク
nnoremap ]m ]`
nnoremap [m [`


" ----------------------------------------
" <t> commands
" ウィンドウ、タブ、バッファの分割・移動
" Window Tab Buffer
" ----------------------------------------
" nnoremap <silent> <C-t>n :echo noaction<CR>
" nnoremap <silent> <C-t><C-n> :echo noaction<CR>
" nnoremap <silent> <C-t>p :echo noaction<CR>
" nnoremap <silent> <C-t><C-p> :echo noaction<CR>
"
" タブの操作
nnoremap <silent> <C-w>n :<C-u>tabnext<CR>
nnoremap <silent> <C-w><C-n> :<C-u>tabnext<CR>
nnoremap <silent> <C-w>p :<C-u>tabprevious<CR>
nnoremap <silent> <C-w><C-p> :<C-u>tabprevious<CR>

" nnoremap <silent> <C-w>1 :<C-u>tabn 1<CR>
" nnoremap <silent> <C-w>2 :<C-u>tabn 2<CR>
" nnoremap <silent> <C-w>3 :<C-u>tabn 3<CR>
" nnoremap <silent> <C-w>4 :<C-u>tabn 4<CR>
" nnoremap <silent> <C-w>5 :<C-u>tabn 5<CR>
" nnoremap <silent> <C-w>6 :<C-u>tabn 6<CR>
" nnoremap <silent> <C-w>7 :<C-u>tabn 7<CR>
" nnoremap <silent> <C-w>8 :<C-u>tabn 8<CR>
" nnoremap <silent> <C-w>9 :<C-u>tabn 9<CR>
" nnoremap <silent> <C-w>0 :<C-u>tabn 10<CR>

" nnoremap <silent> <C-w>c :<C-u>tabnew<CR>:tabmove<CR>
" nnoremap <silent> <C-w><C-c> :<C-u>tabnew<CR>:tabmove<CR>
nnoremap <silent> <C-w>t :<C-u>tabnew<CR>:tabmove<CR>
nnoremap <silent> <C-w><C-t> :<C-u>tabnew<CR>:tabmove<CR>
nnoremap <silent> <C-w><C-w> :<C-u>tabclose<CR>

" nnoremap <silent> <C-n> :<C-u>tabnew<CR>:tabmove<CR>
" nnoremap <silent> <C-w> :echo noaction<CR>
" nnoremap <silent> <C-w>\ <C-w>_<C-w><bar>

nnoremap <a-1> <C-w>1w
nnoremap <a-2> <C-w>2w
nnoremap <a-3> <C-w>3w
nnoremap <a-4> <C-w>4w
nnoremap <a-5> <C-w>5w
nnoremap <a-6> <C-w>6w
nnoremap <a-7> <C-w>7w
nnoremap <a-8> <C-w>8w
nnoremap <a-9> <C-w>9w

" nnoremap <C-z> `.zz

".edit config
nnoremap <silent> <Leader>es :<C-u>source ~/.config/nvim/init.vim<CR>
nnoremap <silent> <Leader>ev :<C-u>e ~/.config/nvim/init.vim<CR>
nnoremap <silent> <Leader>et :<C-u>e ~/.config/nvim/dein.toml<CR>
nnoremap <silent> <Leader>ec :<C-u>CocConfig<CR>
nnoremap <silent> <Leader>eu :<C-u>call dein#update()
nnoremap <silent> <Leader>eu :<C-u>call dein#update()
" call dein#recache_runtimepath()

" cursor
" nnoremap <leader>c :execute '!cursor . && cursor -g '.expand('%:S').':'.line('.')<CR>
nnoremap <leader>c :execute '!cursor -g '.expand('%:S').':'.line('.')<CR>


" reload file
" nnoremap <silent> <Leader>R :<C-u>e<CR>

" help
" nnoremap          <Leader>H :vert help<space>

" save and quit
" nnoremap <silent> <Leader>w :w<CR>
" nnoremap <silent> <Leader>W :wa!<CR>
" nnoremap <silent> <Leader>q :q<CR>
" nnoremap <silent> <Leader>Q :qa!<CR>
" nnoremap <silent> <Leader>w :echo "noaction"<CR>
" nnoremap <silent> <Leader>W :echo "noaction"<CR>
nnoremap <silent> <Leader>q :q<CR>
nnoremap <silent> <Leader>Q :qa!<CR>
nnoremap <silent> <C-s> :w<CR>
nnoremap <silent> <C-w>w :q<CR>
nnoremap <silent> <C-w><C-w> :q<CR>
nnoremap <silent> <C-w>W :qa!<CR>


function! InsertFilenameWithoutExtension()
  let l:filename = expand('%:t:r')
  call feedkeys(l:filename, 'n')
  return ''
endfunction

cnoremap <C-R><C-E> <C-R>=InsertFilenameWithoutExtension()<CR>

" jump same indent
nnoremap <silent> <C-k> k:call search ("^". matchstr (getline (line (".")+ 1), '\(\s*\)') ."\\S", 'b')<CR>^
nnoremap <silent> <C-j> :call search ("^". matchstr (getline (line (".")), '\(\s*\)') ."\\S")<CR>^

if dein#tap('fzf.vim')
  " map <Leader>f [fzf]
  nnoremap <silent> <C-p>     :<C-u>Files<CR>
  nnoremap <silent> <Leader>f :<C-u>FilesWithQuery <C-R>=expand('%:t:r')<CR><CR>
  nnoremap          <Leader>F :<C-u>FilesWithQuery '<C-R><C-W><CR>
  nnoremap <silent> <Leader>ee :<C-u>Dotfiles<CR>
  nnoremap <silent> <Leader>b :<C-u>Buffers<CR>
  nnoremap <silent> <Leader>m :<C-u>Marks<CR>
  nnoremap          <Leader>a :<C-u>Rg<Space>
  nnoremap          <Leader>A :<C-u>Rg <C-r><C-w>

  nnoremap <silent> <Leader>/ :<C-u>BLines<CR>
  nnoremap <silent> <Leader>? :<C-u>Lines<CR>
  nnoremap <silent> <Leader>h :<C-u>History<CR>
  nnoremap <silent> <Leader>H :<C-u>Helptags<CR>
  " nnoremap <silent> <Leader>t :call fzf#vim#tags(expand('<cword>'))<CR>
  " nnoremap <silent> <Leader>T :<C-u>Tags<CR>
  nnoremap <silent> <Leader>J :<C-u>Jump<CR>
endif

if dein#tap('coc.nvim')

  " ポップアップメニュー
  " 補完モードのコマンド(|popupmenu-keys| を参照)
  " <CR>で補完せず下の行
  " <Tab>で補完 スニペットのジャンプ
  " imap <silent><script><expr> <TAB> coc#pum#visible() ?
  "      \     coc#_select_confirm() :
  "      \     coc#expandableOrJumpable() ?
  "      \         "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
  "      \         <SID>check_back_space() ?
  "      \             "\<TAB>" :
  "      \             coc#refresh()
  imap <silent><script><expr> <S-TAB> coc#pum#visible() ?
       \     coc#_select_confirm() :
       \     coc#expandableOrJumpable() ?
       \         "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
       \         <SID>check_back_space() ?
       \             "\<TAB>" :
       \             coc#refresh()

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  nnoremap <silent> <C-l> :<C-u>source ~/.config/nvim/init.vim<CR>:<C-u>Reload<CR>


  " C-Sで0文字でもポップアップメニューを開く
  inoremap <silent><expr> <C-S> coc#refresh()


  " Use `g[` and `g]` to navigate diagnostics
  " エラーのある位置までジャンプ
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)

  " Remap keys for gotos
  " 定義ジャンプ
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gt <Plug>(coc-type-definition)
  nmap <silent> gr <Plug>(coc-references)
  nmap <silent> gi <Plug>(coc-implementation)
  nnoremap <silent> gD :call <SID>show_documentation()<CR>
  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  nnoremap <silent><nowait><expr> <C-S-n> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-S-n>"
  nnoremap <silent><nowait><expr> <C-S-p> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-S-p>"
  inoremap <silent><nowait><expr> <C-S-n> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-S-p> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-S-n> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-S-n>"
  vnoremap <silent><nowait><expr> <C-S-p> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-S-p>"

  " autocomplete
  inoremap <silent><expr> <C-n> coc#pum#visible() ? coc#pum#next(1) : "\<C-n>"
  inoremap <silent><expr> <C-p> coc#pum#visible() ? coc#pum#prev(1) : "\<C-p>"
  inoremap <silent><expr> <Enter> coc#pum#visible() ? coc#pum#confirm() : "\<Enter>"
  inoremap <silent><expr> <Esc> coc#pum#visible() ? coc#pum#cancel() : "\<Esc>"
  inoremap <silent><expr> <C-h> coc#pum#visible() ? coc#pum#cancel() : "\<C-h>"

  " Introduce function text object
  " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
  xmap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap if <Plug>(coc-funcobj-i)
  omap af <Plug>(coc-funcobj-a)

  " Remap for rename current word
  " リネーム
  nmap <silent> gR <Plug>(coc-rename)

  " Remap for format selected region
  " 整形
  xmap <silent> gF <Plug>(coc-format-selected)
  " nmap <silent> gF <Plug>(coc-format-selected)
  nnoremap <silent> gF :<C-u>Format<CR>

  " 折りたたみ
  " nnoremap <silent> gF :<C-u>Fold<CR>

  " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
  " 選択ファイルを関数化したり、別ファイルに書き出したり
  xmap <silent> ga <Plug>(coc-codeaction-selected)
  " nmap <silent> ga <Plug>(coc-codeaction-selected)

  " Remap for do codeAction of current line
  " actionのカレント行バージョン
  nmap <silent> ga  <Plug>(coc-codeaction)

  " Fix autofix problem of current line
  " エラーの自動修正
  nmap <silent> gA  <Plug>(coc-fix-current)
  nmap gq <Plug>(coc-refactor)

  " Convert visual selected code to snippet
  nnoremap <silent> gS  :<C-u>CocCommand snippets.editSnippets<cr>
  xmap <silent> gS  <Plug>(coc-convert-snippet)

  " Use <tab> for select selections ranges, needs server support, like: coc-tsserver, coc-python
  " 謎
  " nmap <silent> <TAB> <Plug>(coc-range-select)
  " xmap <silent> <TAB> <Plug>(coc-range-select)
  " xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)

  " Using CocList
  " Show all diagnostics
  nnoremap <silent> gld  :<C-u>CocList diagnostics<cr>
  " " Manage extensions
  nnoremap <silent> gle  :<C-u>CocList extensions<cr>
  " " Show commands
  nnoremap <silent> glc  :<C-u>CocList commands<cr>
  " Find symbol of current document
  nnoremap <silent> glo  :<C-u>CocList outline<cr>
  " Search workspace symbols
  nnoremap <silent> gls  :<C-u>CocList -I symbols<cr>
  " " Do default action for next item.
  " nnoremap <silent> gj  :<C-u>CocNext<CR>
  " " Do default action for previous item.
  " nnoremap <silent> gk  :<C-u>CocPrev<CR>
  " " Resume latest coc list
  " nnoremap <silent> gp  :<C-u>CocListResume<CR>
  " Open marketplace
  nnoremap <silent> glm  :<C-u>CocList marketplace<cr>

  nnoremap <silent> ge :<C-u>CocCommand explorer<CR>
  nnoremap <silent> gE :<C-u>CocCommand explorer --preset floating<CR>

  nnoremap <silent> gy :<C-u>CocList -A --normal yank<cr>
endif

" --------------------
" vimspector
" --------------------
" if dein#tap('vimspector')
" F5	<Plug>VimspectorContinue	When debugging, continue. Otherwise start debugging.
" Shift F5	<Plug>VimspectorStop	Stop debugging.
" Ctrl Shift F5	<Plug>VimspectorRestart	Restart debugging with the same configuration.
" F6	<Plug>VimspectorPause	Pause debuggee.
" F8	<Plug>VimspectorJumpToNextBreakpoint	Jump to next breakpoint in the current file.
" Shift F8	<Plug>VimspectorJumpToPreviousBreakpoint	Jump to previous breakpoint in the current file.
" F9	<Plug>VimspectorToggleBreakpoint	Toggle line breakpoint on the current line.
" Shift F9	<Plug>VimspectorAddFunctionBreakpoint	Add a function breakpoint for the expression under cursor
" F10	<Plug>VimspectorStepOver	Step Over
" F11	<Plug>VimspaatorStepInto	Step Into
" Shift F11	<Plug>VimspectorStepOut	Step out of current function scope
" Alt 8	`VimspectorDisassemble	Show disassembly
" endif

if dein#tap('copilot.vim')
  imap <silent><script><expr> <Tab> copilot#Accept("\<Tab>")
  imap <silent> <a-]> <Plug>(copilot-next)
  imap <silent> <a-[> <Plug>(copilot-previous)
  imap <silent> <c-/> <Plug>(copilot-suggest)
  " nnoremap <Leader>c :Copilot disable<CR>
  " nnoremap <Leader>C :Copilot enable<CR>

  let g:copilot_filetypes = {
    \ '*': v:false,
    \ 'ruby': v:true,
    \ 'typescript': v:true,
    \ 'javascript': v:true,
    \ 'typescriptreact': v:true,
    \ 'javascriptreact': v:true,
    \ }

  " let g:copilot_filetypes = {
  "   \ '*': v:false,
  "   \ }

  let g:copilot_no_tab_map = v:true

  " augroup copilot
  "   autocmd!
  "   autocmd VimEnter * Copilot disable
  " augroup End
endif

" if dein#tap('vista.vim')
"   nnoremap <silent> <Leader>o :<C-u>Vista coc<CR>
" endif


if dein#tap('PDV--phpDocumentor-for-Vim')
  augroup php-dev
    autocmd!
    autocmd FileType php nnoremap <Leader>P :call PhpDocSingle()<CR>
    autocmd FileType php vnoremap <Leader>P :call PhpDocRange()<CR>
  augroup End
endif

if dein#tap('vim-php-cs-fixer')
  " If you use php-cs-fixer version 2.x
  let g:php_cs_fixer_rules = "@PSR12"          " options: --rules (default:@PSR2)
  let g:php_cs_fixer_cache = ".php-cs-fixer.cache" " options: --cache-file
  let g:php_cs_fixer_config_file = '.php-cs-fixer.dist.php' " options: --config

  let g:php_cs_fixer_php_path = "php"               " Path to PHP
  let g:php_cs_fixer_enable_default_mapping = 0     " Enable the mapping by default (<leader>pcd)
  let g:php_cs_fixer_dry_run = 0                    " Call command with dry-run option
  let g:php_cs_fixer_verbose = 0                    " Return the output of command if 1, else an inline information.
endif

if dein#tap('vim-easy-align')
  " Start interactive EasyAlign in visual mode (e.g. vipga)
  " xmap <Leader>A <Plug>(EasyAlign)
  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  " nmap <Leader>A <Plug>(EasyAlign)
endif

if dein#tap('caw.vim')
  let g:caw_operator_keymappings = 0
  " 行の最初の文字の前にコメント文字をトグル
  " nmap gc <Plug>(caw:hatpos:toggle)
  " nmap gC <Plug>(caw:wrap:toggle)
  " vmap gc <Plug>(caw:hatpos:toggle)
  " vmap gC <Plug>(caw:wrap:toggle)
endif

" if dein#tap('nerdcommenter')
"   nmap gcc <plug>NERDCommenterToggle
"   vmap gcc <plug>NERDCommenterToggle
" endif


if dein#tap('incsearch-migemo.vim')
  nmap <silent> g/ <Plug>(incsearch-migemo-/)
  " nmap g? <Plug>(incsearch-migemo-?)
endif

" if dein#tap('vim-rengbang')
"   map <Leader>R <Plug>(operator-rengbang)
" endif

nnoremap <leader>s :<C-u>%s/\v
vnoremap <leader>s :<C-u>'<,'>s/\v
cnoreabbrev <expr> s getcmdtype() .. getcmdline() ==# ':s' ? [getchar(), ''][1] .. "%s///g<Left><Left>" : 's'

if dein#tap('vim-easymotion')
  map  f <Plug>(easymotion-fl)
  map  F <Plug>(easymotion-Fl)
  map  t <Plug>(easymotion-tl)
  map  T <Plug>(easymotion-Tl)

  nmap <Leader>[ <Plug>(easymotion-overwin-f2)
  vmap <Leader>[ <Plug>(easymotion-bd-f2)

  " Move to line
  map <Leader>j <Plug>(easymotion-j)
  map <Leader>k <Plug>(easymotion-k)
endif

if dein#tap('vim-choosewin')
  " nmap <C-w>w  <Plug>(choosewin)
  " nmap <C-w><C-w>  <Plug>(choosewin)
endif


if dein#tap('vim-sandwich')
  runtime macros/sandwich/keymap/surround.vim
  xmap S <Nop>
  xmap s <Plug>(operator-sandwich-add)
endif

map <Leader>g [git]
if dein#tap("vim-fugitive")
  nnoremap [git]g :<C-u>GFiles?<CR>
  nnoremap [git]f :<C-u>GFiles?<CR>
  nnoremap [git]w :Git status<CR>
  nnoremap [git]c :Git commit<CR>
  " nnoremap [git]d :Git diff<CR>
  nnoremap [git]d :Gdiff<CR>
  nnoremap [git]b :Git blame<CR>
  nnoremap [git]B :GBrowse<CR>
  vnoremap [git]B :'<,'>GBrowse<CR>
endif

if dein#tap("agit.vim")
  nnoremap [git]l :Agit<CR>
endif

if dein#tap('vim-gitgutter')
  nmap ]h <Plug>(GitGutterNextHunk)
  nmap [h <Plug>(GitGutterPrevHunk)

  nmap [git]p <Plug>(GitGutterPreviewHunk)
  nmap [git]a <Plug>(GitGutterStageHunk)
  nmap [git]r <Plug>(GitGutterUndoHunk)
  nmap [git]t <Plug>(GitGutterLineHighlightsToggle)
endif

" if dein#tap('vim-table-mode')
"   let g:table_mode_disable_mappings = 0

"   let g:table_mode_map_prefix = "<C-t>"
"   let g:table_mode_corner = "|"
"   let g:table_mode_toggle_map = 'm'

"   let g:table_mode_motion_up_map = '<C-t>k'
"   let g:table_mode_motion_down_map = '<C-t>j'
"   let g:table_mode_motion_left_map = '<C-t>h'
"   let g:table_mode_motion_right_map = '<C-t>l'

"   " 以下ノーマルモード
"   let g:table_mode_tableize_map = '<C-t>T'
"   let g:table_mode_tableize_d_map = '<C-t>t'
"   let g:table_mode_realign_map = '<C-t>r'
"   let g:table_mode_delete_row_map = '<C-t>dr'
"   let g:table_mode_delete_column_map = '<C-t>dc'
"   " let g:table_mode_add_formula_map = '<C-t>fa'
"   " let g:table_mode_eval_formula_map = '<C-t>fe'
"   let g:table_mode_echo_cell_map = '<C-t>?'
"   " let g:table_mode_sort_map = '<C-t>s'
" endif

if dein#tap('vim-maketable')
  " nnoremap <c-t>t :MakeTable<CR>
endif

if dein#tap('memolist.vim')
  nnoremap <Leader>mn  :MemoNew<CR>
  nnoremap <Leader>ml  :MemoListFzf<CR>
  nnoremap <Leader>mg  :MemoGrepFzf<SPACE>
  nnoremap <Leader>md  :MemoDaily<CR>
  nnoremap <Leader>mi  :MemoNew<CR>
endif

if dein#tap('tagbar')
  nnoremap <Leader>O :TagbarToggle<CR>
endif

" if dein#tap('yankround.vim')
"   nmap p <Plug>(yankround-p)
"   xmap p <Plug>(yankround-p)
"   nmap P <Plug>(yankround-P)
"   nmap gp <Plug>(yankround-gp)
"   xmap gp <Plug>(yankround-gp)
"   nmap gP <Plug>(yankround-gP)
"   nmap <Buffer><C-p> <Plug>(yankround-prev)
"   nmap <Buffer><C-n> <Plug>(yankround-next)
" endif

if dein#tap('vim-openapi')
  nnoremap <Leader>c :OpenAI<SPACE>
endif

if dein#tap('vim-markdown')
  autocmd FileType markdown nnoremap <silent><buffer> + :<C-u>.HeaderIncrease<CR>
  autocmd FileType markdown nnoremap <silent><buffer> - :<C-u>.HeaderDecrease<CR>
  autocmd FileType markdown vnoremap <silent><buffer> + :<C-u>'<,'>HeaderIncrease<CR>
  autocmd FileType markdown vnoremap <silent><buffer> - :<C-u>'<,'>HeaderDecrease<CR>

  let g:vim_markdown_folding_disabled = 1
  let g:vim_markdown_no_default_key_mappings = 1
  let g:vim_markdown_new_list_item_indent = 0

  let g:vim_markdown_conceal = 0
endif

" if dein#tap('markdown-preview.nvim')
"   autocmd FileType markdown nmap <silent><buffer> <Leader><Bslash> <Plug>MarkdownPreviewToggle
" endif

if dein#tap('previm')
  autocmd FileType markdown nnoremap <silent><buffer> <Leader><Bslash> :<C-U>PrevimOpen<CR>
endif

if dein#tap("vim-rails")
  " https://qiita.com/bibio/items/ac3f0cb8e7949b2ce56c
  map <Leader>r [rails]

  " alternate file (test)
  nnoremap [rails]r :A<CR>
  " 以下はどの画面で開くか
  " nnoremap [rails]ae :AE<CR>
  " nnoremap [rails]as :AS<CR>
  " nnoremap [rails]av :AV<CR>
  " nnoremap [rails]at :AT<CR>
  " nnoremap [rails]ad :AD<CR>

  " related file (test)
  nnoremap [rails]R :R<CR>
  " 以下はどの画面で開くか
  " nnoremap [rails]re :RE<CR>
  " nnoremap [rails]rs :RS<CR>
  " nnoremap [rails]rv :RV<CR>
  " nnoremap [rails]rt :RT<CR>
  " nnoremap [rails]rd :RD<CR>

  " nnoremap [rails]a :<C-u>Rg <C-R>=expand('%:t:r')<CR>

  " app/contollers/xxx_controller.rb
  nnoremap [rails]c :Econtroller<CR>
  " config/application.rb
  nnoremap [rails]e :Eenvironment<CR>

  " test/fixture/xxx.yml
  nnoremap [rails]F :Efixture<CR>
  " app/helpers/xxx_helper.rb
  nnoremap [rails]h :Ehelper<CR>
  " config/routes.rb
  nnoremap [rails]i :Einitializer<CR>
  " app/assets/javascripts/books.js.coffee
  nnoremap [rails]j :Ejavascript<CR>
  " app/views/layouts/application.html.erb
  nnoremap [rails]l :Elayout<CR>
  " Gemfile
  nnoremap [rails]L :Elib<CR>
  " config/locales/en.yml
  nnoremap [rails]o :Elocale<CR>
  " db/migrate/*****_create_xxxx.rb
  nnoremap [rails]m :Emigration<CR>
  "
  nnoremap [rails]M :Emailer<CR>
  " db/schema.rb
  nnoremap [rails]s :Eschema<CR>
  " app/assets/stylesheets/xxxx.css.scss
  nnoremap [rails]S :Estylesheet<CR>
  " test/controllers/xxxx_controller_test.rb
  nnoremap [rails]t :Efunctionaltest<CR>
  " spec/spec_helper.rb
  nnoremap [rails]T :Etask<CR>
  " test/models/test_xxx.rb または spec/models/xxx_spec.rb
  nnoremap [rails]u :Eunittest<CR>
  " app/views/xxxx/yyy.html.erb
  nnoremap [rails]v :Eview<CR>
endif

if dein#tap("cuculus.vim")
  autocmd FileType ruby nnoremap <silent><buffer> % :<C-u>call cuculus#jump()<CR>
end

augroup ruby
  autocmd!
  autocmd FileType ruby let b:did_ftplugin = 1
augroup end

" let g:ruby_host_prog = $HOME."/.rbenv/shims/neovim-ruby-host"

" --------------------
" Keymap ここまで
" --------------------





" --------------------
" setting ここから
" --------------------
"--------------------
" fzf.vim
"--------------------

let g:dotfiles_path = substitute(system("cd $(dirname ".$MYVIMRC."); git rev-parse --show-toplevel"), "[\n\r]", "", "g")
if dein#tap('fzf.vim')

  " TODO: 多分遅い
  function! s:build_quickfix_list(lines)
    if len(a:lines) == 1
      execute 'edit '.a:lines[0]
    else
      call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
      copen
      " cc
    endif
  endfunction

  function! s:fzf_emoji(...) abort
    if a:0 >= 1
      let l:file = a:1
    else
      let l:file = "*"
    endif
    call fzf#run({
          \ 'source': 'cat ~/.config/nvim/cheatsheet/emoji/'.l:file,
          \ 'sink': function('s:insert_emoji'),
          \ 'down': '40%'
          \ })
  endfunction

  function! s:insert_emoji(line) abort
    let l:splitted = split(a:line)

    if l:splitted[0] == "*"
      call s:fzf_emoji(l:splitted[1])
    else
      let pos = getpos(".")
      execute ":normal i" . l:splitted[1]
      call setpos('.', pos)
    endif
  endfunction

  function! s:get_jumplist() abort
    redir => cout
    silent jumps
    redir END
    return reverse(split(cout, "\n")[1:])
  endfunction

  function! s:go_to_jump(jump)
    let jumpnumber = split(a:jump, '\s\+')[0]
    execute "normal " . jumpnumber . "\<c-o>"
  endfunction

  function! s:fzf_jump(...) abort
    call fzf#run({
        \ 'source': s:get_jumplist(),
        \ 'sink': function('s:go_to_jump'),
        \ 'down': '40%'
        \ })
  endfunction

  command! Jump call s:fzf_jump()

  function! s:FilesWithQuery(query)
    call fzf#run(fzf#wrap({
          \ 'source': 'fd',
          \ 'options': ['--query', a:query]
          \ }))
  endfunction
  command! -nargs=? FilesWithQuery call s:FilesWithQuery(<q-args>)

  " This is the default extra key bindings
  let g:fzf_action = {
        \ 'enter': function('s:build_quickfix_list'),
        \ 'ctrl-m': 'open',
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit'}


  let g:fzf_buffers_jump = 1
  " let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
  let g:fzf_tags_command = 'ctags --exclude=node_modules --exclude=vendor'

  command! -bang -nargs=? -complete=dir Dotfiles
        \ call fzf#vim#files(g:dotfiles_path, <bang>0)

  command! -nargs=? Emoji call s:fzf_emoji(<f-args>)
  command! -bang -nargs=+ -complete=dir Ag call fzf#vim#ag_raw(<q-args>, <bang>0)

  command! -bang -nargs=* -complete=dir MemoListFzf
       \  call fzf#vim#files(g:memolist_path, <bang>0)

  command! -bang -nargs=* -complete=dir MemoGrepFzf
       \  call fzf#vim#grep(
       \    'rg --column --line-number --no-heading --color=always --smart-case -M0 -sortr path'.(<q-args>) . ' ' . g:memolist_path, 1,
       \    <bang>0 ? fzf#vim#with_preview('up:60%')
       \            : fzf#vim#with_preview('right:50%:hidden'),
       \    <bang>0)

  command! -bang -nargs=* -complete=dir Rg
        \  call fzf#vim#grep(
        \    'rg --column --line-number --no-heading --color=always --smart-case -M0 '.(<q-args>), 1,
        \    <bang>0 ? fzf#vim#with_preview('up:60%')
        \            : fzf#vim#with_preview('right:50%:hidden'),
        \    <bang>0)

  " Likewise, Files command with preview window
  command! -bang -nargs=? -complete=dir Files
        \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

  " function! s:fzf_statusline()
  "   set statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
  " endfunction
  " autocmd!  FzfStatusLine call <SID>fzf_statusline()

  " let g:fzf_layout = { 'window': { 'width': 1.0, 'height': 0.6, 'highlight': 'Todo' } }
  let g:fzf_layout = { 'down': "70%" }
  let g:fzf_colors =
    \ { 'fg':      ['fg', 'Normal'],
      \ 'bg':      ['bg', 'Normal'],
      \ 'hl':      ['fg', 'Comment'],
      \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
      \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
      \ 'hl+':     ['fg', 'Statement'],
      \ 'info':    ['fg', 'PreProc'],
      \ 'border':  ['fg', 'Ignore'],
      \ 'prompt':  ['fg', 'Conditional'],
      \ 'pointer': ['fg', 'Exception'],
      \ 'marker':  ['fg', 'Keyword'],
      \ 'spinner': ['fg', 'Label'],
      \ 'header':  ['fg', 'Comment']
      \ }
endif

" --------------------
" coc.nvim
" --------------------
if dein#tap('coc.nvim')
  set hidden
  set nobackup
  set nowritebackup
  set cmdheight=2
  set updatetime=100
  set shortmess+=cI
  set signcolumn=yes

  " let g:coc_config_home='~/.config/nvim/coc/'
  augroup cocmygroup
    autocmd!
    autocmd FileType * let b:coc_additional_keywords = ["-"]

    " Setup formatexpr specified filetype(s).
    " autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder
    " autocmd  CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    autocmd FileType vue let b:coc_root_patterns = ['.git', '.env', 'package.json', 'tsconfig.json', 'jsconfig.json', 'vite.config.ts', 'vue.config.js', 'nuxt.config.ts', 'tailwind.config.js', 'tailwind.config.ts']
  augroup end

  " Use `:Format` to format current buffer
  command! -nargs=0 Format :call CocAction('format')

  " Use `:Fold` to fold current buffer
  command! -nargs=? Fold :call CocAction('fold', <f-args>)

  " foldmethod
  " manual 手動で折畳を定義する
  " indent インデントの数を折畳のレベル(深さ)とする
  " expr 折畳を定義する式を指定する
  " syntax 構文強調により折畳を定義する
  " diff 変更されていないテキストを折畳対象とする
  " marker テキスト中の印で折畳を定義する
  " set foldmethod=indent
  set foldlevel=1

  " use `:OR` for organize import of current buffer
  command! -nargs=0 OR  :call CocAction('runCommand', 'editor.action.organizeImport')

  " Add status line support, for integration with other plugin, checkout `:h coc-status`
  " set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

  let g:coc_global_extensions = [
        \ 'coc-lists',
        \ 'coc-marketplace',
        \ 'coc-snippets',
        \ 'coc-html',
        \ 'coc-emmet',
        \ 'coc-svg',
        \ 'coc-css',
        \ 'coc-stylelintplus',
        \ '@yaegassy/coc-volar',
        \ '@yaegassy/coc-volar-tools',
        \ '@yaegassy/coc-tailwindcss3',
        \ 'coc-solargraph',
        \ 'coc-tsserver',
        \ 'coc-php-cs-fixer',
        \ 'coc-solargraph',
        \ 'coc-psalm',
        \ 'coc-xml',
        \ 'coc-json',
        \ 'coc-sql',
        \ 'coc-rust-analyzer',
        \ 'coc-diagnostic',
        \ 'coc-go',
        \ 'coc-lua',
        \ 'coc-powershell',
        \ 'coc-explorer',
        \ 'coc-yank',
        \ 'coc-flutter',
        \ ]

        "\ 'coc-eslint',
        "\ 'coc-tailwindcss',
        "\ 'coc-vetur',
        "\ 'coc-yaml',
        "\ 'coc-tabnine',
        "\ 'coc-yaml',
        "\ 'coc-phpls',

  let g:coc_disable_transparent_cursor = 0

  let g:coc_explorer_global_presets = {
    \   'floating': {
    \     'position': 'floating',
    \     'open-action-strategy': 'sourceWindow',
    \   },
    \ }
  augroup coccolorscheme
    autocmd!
    autocmd ColorScheme * hi! link CocExplorerGitDeleted Exception
  augroup end
endif

"" --------------------
"" vista.vim
"" --------------------
if dein#tap('vista.vim')
  let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]
  let g:vista_fold_toggle_icons = ['▼', '▶']

  let g:vista_blink = [0, 0]
  let g:vista_top_level_blink = [0, 0]
  let g:vista_highlight_whole_line = 0
  let g:vista_echo_cursor = 1
  let g:vista_update_on_text_changed = 0
  let g:vista_default_executive = 'ctags'
  let g:vista_sidebar_width = 50
  let g:vista_enable_centering_jump = 1
  let g:vista_fzf_preview = ['right:50%']

  let g:vista#renderer#icons = {
        \    'func': "\uf794",
        \    'function': "\uf794",
        \    'functions': "\uf794",
        \    'var': "\uf71b",
        \    'variable': "\uf71b",
        \    'variables': "\uf71b",
        \    'const': "\uf8ff",
        \    'constant': "\uf8ff",
        \    'constructor': "\uf976",
        \    'method': "\uf6a6",
        \    'package': "\ue612",
        \    'packages': "\ue612",
        \    'enum': "\uf702",
        \    'enummember': "\uf282",
        \    'enumerator': "\uf702",
        \    'module': "\uf136",
        \    'modules': "\uf136",
        \    'type': "\uf7fd",
        \    'typedef': "\uf7fd",
        \    'types': "\uf7fd",
        \    'field': "\uf30b",
        \    'fields': "\uf30b",
        \    'macro': "\uf8a3",
        \    'macros': "\uf8a3",
        \    'map': "\ufb44",
        \    'class': "\uf0e8",
        \    'augroup': "\ufb44",
        \    'struct': "\uf318",
        \    'union': "\ufacd",
        \    'member': "\uf02b",
        \    'target': "\uf893",
        \    'property': "\ufab6",
        \    'interface': "\uf7fe",
        \    'namespace': "\uf475",
        \    'subroutine': "\uf9af",
        \    'implementation': "\uf776",
        \    'typeParameter': "\uf278",
        \    'default': "\uf29c"
        \}
  let g:vista#renderer#enable_icon = 1

  function! NearestMethodOrFunction() abort
    return get(b:, 'vista_nearest_method_or_function', '')
  endfunction

  set statusline+=%{NearestMethodOrFunction()}

  augroup vistacmd
    autocmd!
    autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
    " autocmd BufEnter,BufRead * Vista coc
  augroup END

  augroup vistacolor
    autocmd!
    " autocmd ColorScheme * hi IncSearch term=underline cterm=underline gui=underline

    autocmd ColorScheme * hi link VistaParenthesis Operator
    autocmd ColorScheme * hi link VistaScope       CocListFgRed " Title Function
    autocmd ColorScheme * hi link VistaTag         CocListFgBlue " Type Keyword
    " autocmd ColorScheme * hi VistaTag term=none cterm=none gui=none " Keyword
    autocmd ColorScheme * hi link VistaKind        CocListFgMagenta " Constant Type
    autocmd ColorScheme * hi link VistaScopeKind   CocListFgGreen "Define
    autocmd ColorScheme * hi link VistaLineNr      LineNr
    autocmd ColorScheme * hi link VistaColon       SpecialKey
    autocmd ColorScheme * hi link VistaIcon        CocListFgYellow
    autocmd ColorScheme * hi link VistaArgs        Comment
  augroup END

  augroup tabninecolor
    autocmd ColorScheme * hi link TabnineSuggestion  Comment
  augroup END


  " CocListFgBlack	CocListFgBlack
  " CocListFgGrey	CocListFgGrey
  " CocListFgWhite	CocListFgWhite
  " CocListFgBlue	CocListFgBlue
  " CocListFgGreen	CocListFgGreen
  " CocListFgCyan	CocListFgCyan
  " CocListFgYellow	CocListFgYellow
  " CocListFgMagenta	CocListFgMagenta
  " CocListFgRed	CocListFgRed

endif

"--------------------
" majutsushi/tagbar
"--------------------
if dein#tap('tagbar')
  " let g:tagbar_autofocus = 1
  let g:tagbar_show_linenumbers = 1
  let g:tagbar_iconchars = ['▸', '▾']
  let g:tagbar_autofocus = 1
  let g:tagbar_sort = 0
  let g:tagbar_width = 60
  " let g:tagbar_ctags_bin = 'ctags --exclude=node_modules --exclude=vendor'

  augroup tagbarhighlight
    autocmd!
    autocmd ColorScheme * hi link TagbarVisibilityPublic Type
    autocmd ColorScheme * hi link TagbarVisibilityProtected String
    " autocmd ColorScheme * hi link TagbarVisibilityPrivate Special
    autocmd ColorScheme * hi link TagbarVisibilityPrivate Todo
    " autocmd ColorScheme * hi link TagbarHighlight Visual
    " autocmd ColorScheme * hi TagbarHighlight term=underline cterm=underline gui=underline
    autocmd ColorScheme * hi TagbarHighlight term=underline cterm=underline gui=underline
  augroup END

  let g:tagbar_type_yaml = {
        \ 'ctagstype' : 'yaml',
        \ 'kinds' : [
        \ 'a:anchors',
        \ 's:section',
        \ 'e:entry'
        \ ],
        \ 'sro' : '.',
        \ 'scope2kind': {
        \ 'section': 's',
        \ 'entry': 'e'
        \ },
        \ 'kind2scope': {
        \ 's': 'section',
        \ 'e': 'entry'
        \ },
        \ 'sort' : 0
        \ }
endif

"----------------------
" easymotion
"----------------------
if dein#tap('vim-easymotion')
  let g:EasyMotion_do_mapping = 0 " デフォルトマップを無効化

  let g:EasyMotion_smartcase = 1
  let g:EasyMotion_use_migemo = 1
  let g:EasyMotion_startofline = 0
  let g:EasyMotion_use_upper = 1 " Show target key with upper case to improve readability
  let g:EasyMotion_enter_jump_first = 1
  let g:EasyMotion_space_jump_first = 1
  let g:EasyMotion_do_shade = 0
  let g:EasyMotion_keys = "AWEFJIOPTYUSDKLZXCVBNMGH;"
  "asdf jiop qwert yukl zxcvbnm gh;"
endif
" a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a
"
if dein#tap('vim-choosewin')
  let g:choosewin_overlay_enable = 1
endif

if dein#tap('vim-over')
  let g:over_command_line_prompt = "> "
endif

"------------
" airline
"------------
if dein#tap('vim-airline')
  set ambiwidth=double  " 絵文字>
  " set ambiwidth=single  " 絵文字>
  let g:airline_powerline_fonts = 1
  let g:airline_symbols_ascii = 1

  " let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
  " let g:airline#extensions#tabline#formatter = 'default'

  " let g:airline_section_a = airline#section#create(["mode", " crypt", " paste", " spell", " iminsert"])
  let g:airline_section_b = airline#section#create([])
  " let g:airline_section_c = airline#section#create([])
  " let g:airline_section_gutter = airline#section#create([])
  let g:airline_section_x = airline#section#create([])
  let g:airline_section_y = airline#section#create([])
  let g:airline_section_z = airline#section#create([])

  let g:airline#extensions#tabline#enabled = 1
  let g:airline_filetype_overrides = {
        \ 'coc-explorer':  [ 'CoC Explorer', '' ],
        \ }
        " \ 'fugitive': ['fugitive', '%{airline#util#wrap(airline#extensions#branch#get_head(),80)}'],
  let g:airline_exclude_filetypes = [ 'dap-repl', 'dapui_console', 'dapui_scopes', 'dapui_breakpoints', 'dapui_stacks', 'dapui_watches' ]

  let g:airline#extensions#tabline#fnamemod = ':t' " タブに表示する名前（fnamemodifyの第二引数）
  let g:airline#extensions#tabline#show_splits = 1 "enable/disable displaying open splits per tab (only when tabs are opened). >
  let g:airline#extensions#tabline#show_buffers = 0 " enable/disable displaying buffers with a single tab
  let g:airline#extensions#tabline#tab_nr_type = 0 " 0でそのタブで開いてるウィンドウ数、1で左のタブから連番
  let g:airline#extensions#tabline#switch_buffers_and_tabs = 1
  let airline#extensions#tabline#current_first = 0

  let g:airline_section_x = ''
  let g:airline_section_y = ''

 " let g:airline_section_a = ' ✚ %L'    " 例: 現在のバッファ番号を表示
" let g:airline_section_b = '  %m'    " 例: ファイルの状態を表示
" let g:airline_section_c = ' %f'       " 例: ファイル名を表示 let g:airline_section_z = ''

  let g:airline#extensions#tabline#tabtitle_formatter = 'MyTabTitleFormatter'
  function MyTabTitleFormatter(n)
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let bufname =  bufname(buflist[winnr - 1])
    let filename = fnamemodify(bufname, ":t:r")
    let extension = fnamemodify(bufname, ":e")
    if extension != ""
      let label = filename . "." . extension
    else
      let label = filename
    endif
    return label
  endfunction
endif

"--------------------
"vim-quickrun
"--------------------
if dein#tap("vim-quickrun")
  nnoremap <Leader>\ :w<CR>:QuickRun<CR>
  autocmd FileType quickrun setlocal nofoldenable
  let g:quickrun_config = {}
  let g:quickrun_no_default_key_mappings = 1
  let g:quickrun_config.scheme = { 'scheme': { 'command': 'gosh'}}
  let g:quickrun_config.rust = {'exec' : 'cargo run'}
  let g:quickrun_config['typescript'] = { 'type' : 'typescript/tsc' }
  let g:quickrun_config['typescript/tsc'] = {
        \   'command': 'tsc',
        \   'exec': ['%c --target esnext --module commonjs %o %s', 'node %s:r.js'],
        \   'tempfile': '%{tempname()}.ts',
        \   'hook/sweep/files': ['%S:p:r.js'],
        \ }
endif

"--------------------
" qfreplace
"--------------------
if dein#tap("vim-qfreplace")
  autocmd FileType qf nnoremap <silent> <buffer> r :Qfreplace<CR>
endif

"--------------------
" kana/vim-smartinput
"--------------------
if dein#tap('vim-smartinput')
  call smartinput#map_to_trigger('i', '<Space>', '<Space>', '<Space>')
  call smartinput#define_rule({
        \   'at'    : '(\%#)',
        \   'char'  : '<Space>',
        \   'input' : '<Space><Space><Left>',
        \   })

  call smartinput#define_rule({
        \   'at'    : '( \%# )',
        \   'char'  : '<BS>',
        \   'input' : '<Del><BS>',
        \   })

  call smartinput#define_rule({
        \   'at': '\s\+\%#',
        \   'char': '<CR>',
        \   'input': "<C-o>:call setline(line('.'), substitute(getline(line('.')), '\\s\\+$', '', ''))<CR><CR>",
        \   })

  " call smartinput#map_to_trigger('i', '<bar>', '<bar>', '<bar>')
  " call smartinput#define_rule({
  "       \  'at': '^\%#',
  "       \  'char': '<bar>',
  "       \  'input': '<c-o>:TableModeEnable<cr><bar><space>',
  "       \  })

  call smartinput#map_to_trigger('i', '<Bar>', '<Bar>', '<Bar>')
  call smartinput#define_rule({
        \    'at': '\%#',
        \    'char': '<Bar>',
        \    'input': '<Bar><Bar><Left>',
        \    'filetype': ['rust', 'ruby'],
        \ })
  call smartinput#define_rule({
        \    'at': '\%#|',
        \    'char': '<Bar>',
        \    'input': '<Right>',
        \    'filetype': ['rust', 'ruby'],
        \ })
  call smartinput#define_rule({
        \    'at': '|\%#|',
        \    'char': '<BS>',
        \    'input': '<BS><Del>',
        \    'filetype': ['rust', 'ruby'],
        \ })
  call smartinput#define_rule({
        \    'at': '||\%#',
        \    'char': '<BS>',
        \    'input': '<BS><BS>',
        \    'filetype': ['rust', 'ruby'],
        \ })
  call smartinput#define_rule({
        \    'at': '\\\%#',
        \    'char': '<Bar>',
        \    'input': '<Bar>',
        \    'filetype': ['rust', 'ruby'],
        \ })
endif

"--------------------
" docteurklein/vim-symfony
"--------------------
if dein#tap('vim-symfony')
  let g:symfony_app_console_caller= "php"
  let g:symfony_app_console_path= "bin/console"
  let g:symfony_enable_shell_mapping = 0 "disable the mapping of symfony console
endif

"--------------------
" committia
"--------------------
if dein#tap('committia.vim')
  let g:committia_hooks = {}
  " function! g:committia_hooks.edit_open(info)
  "   " Additional settings
  "   setlocal spell
  "
  "   " If no commit message, start with insert mode
  "   if a:info.vcs ==# 'git' && getline(1) ==# ''
  "     startinsert
  "   endif
  "
  "   " Scroll the diff window from insert mode
  "   " Map <C-n> and <C-p>
  "   imap <buffer><C-n> <Plug>(committia-scroll-diff-down-half)
  "   imap <buffer><C-p> <Plug>(committia-scroll-diff-up-half)
  " endfunction
endif

"--------------------
" vim-asciidoctor
"--------------------
if dein#tap('vim-asciidoctor')
  let g:asciidoctor_executable = 'asciidoctor'
  " let g:asciidoctor_extensions = ['asciidoctor-diagram', 'asciidoctor-rouge']
  " asciidoctor-pdf
  " let g:asciidoctor_pdf_executable = 'asciidoctor-pdf'
  " let g:asciidoctor_pdf_extensions = ['asciidoctor-diagram']
  let g:asciidoctor_folding = 1
  let g:asciidoctor_fold_options = 1
  let g:asciidoctor_syntax_conceal = 1
  let g:asciidoctor_syntax_indented = 0
  let g:asciidoctor_fenced_languages = ['python', 'c', 'javascript']
  fun! AsciidoctorMappings()
    " noremap <Leader>A [Adoc]
    " nnoremap <buffer> [Adoc]o :AsciidoctorOpenRAW<CR>
    " nnoremap <buffer> [Adoc]oh :AsciidoctorOpenHTML<CR>
    nnoremap <buffer> [Adoc] :AsciidoctorOpenPDF<CR>
    " nnoremap <buffer> [Adoc]ox :AsciidoctorOpenDOCX<CR>
    " nnoremap <buffer> [Adoc]ch :Asciidoctor2HTML<CR>
    " nnoremap <buffer> [Adoc]cp :Asciidoctor2PDF<CR>
    " nnoremap <buffer> [Adoc]cx :Asciidoctor2DOCX<CR>
    " nnoremap <buffer> [Adoc]p :AsciidoctorPasteImage<CR>
    " :make will build pdfs
    " compiler asciidoctor2pdf
  endfun
  " " Call AsciidoctorMappings for all `*.adoc` and `*.asciidoc` files
  augroup asciidoctor
    au!
    au BufEnter *.adoc,*.asciidoc call AsciidoctorMappings()
  augroup END
endif

"--------------------
" memolist
"--------------------
if dein#tap('memolist.vim')
  let g:memolist_memo_suffix = "md"
  let g:memolist_path = $HOME."/memo/Inbox"

  let g:memolist_memo_date = "%Y/%m/%d %H:%M:%S"
  let g:memolist_filename_date = "%Y%m%d-"
  let g:memolist_template_dir_path = $HOME."/memo/Templates/default.md"

  let g:memolist_prompt_tags = 1
  let g:memolist_prompt_categories = 0
  let g:memolist_fzf = 1

  function! s:memo_daily()
    let s:memo_path = system('memo daily')
    execute 'edit '.s:memo_path
  endfunction
  command! MemoDaily call s:memo_daily()
endif

"--------------------
" markdown-preview.nvim
"--------------------
if dein#tap('markdown-preview.nvim')
  let g:mkdp_auto_close = 1

  let g:mkdp_refresh_slow = 1

  " preview page title
  " ${name} will be replace with the file name
  let g:mkdp_page_title = '「${name}」'
endif
"--------------------
" previm
"--------------------
if dein#tap("previm")
  let g:previm_disable_default_css = 1
  let g:previm_custom_css_path = '~/.config/nvim/templates/previm/github.css'
endif

"--------------------
" vim-gitgutter
"--------------------
if dein#tap('vim-gitgutter')
  let g:gitgutter_enabled = 1
  let g:gitgutter_map_keys = 0
  let g:gitgutter_max_signs = 2000
  let g:gitgutter_signs = 1
  let g:gitgutter_highlight_linenrs = 0
  let g:gitgutter_sign_allow_clobber = 1
endif

"--------------------
" vim-php-cs-fixer
"--------------------
if dein#tap('vim-php-cs-fixer')
  " If you use php-cs-fixer version 2.x
  " options: --rules (default:@PSR2)
  " let g:php_cs_fixer_rules = '{ '
  "     \ . '"@PSR1": true, '
  "     \ . '"@PSR2": true,'
  "     \ . '"@Symfony": true,'
  "     \ . '"braces": { "position_after_control_structures":  "next", "position_after_anonymous_constructs": "next" }'
  "     \ . ' }t]n'
  let g:php_cs_fixer_cache = ".php_cs.cache" " options: --cache-file
  let g:php_cs_fixer_config_file = '.php_cs' " options: --config

  let g:php_cs_fixer_php_path = "php"               " Path to PHP
  let g:php_cs_fixer_enable_default_mapping = 0     " Enable the mapping by default (<leader>pcd)
  let g:php_cs_fixer_dry_run = 0                    " Call command with dry-run option
  let g:php_cs_fixer_verbose = 0                    " Return the output of command if 1, else an inline information.
endif

"--------------------
" nvim-colorizer
"--------------------
if dein#tap('nvim-colorizer')
lua << EOF
lua require'colorizer'.setup()
EOF
endif

"--------------------
" vim-sandwich
"--------------------
if dein#tap('vim-sandwich')
  let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
  let g:sandwich#recipes += [
        \    {'buns': ['<', '>']}
        \  ]
endif

" if dein#tap('airsave.vim')
"   let g:auto_write = 0
" endif

function! s:open_code()
  let s:repo_path = system('cd '.expand('%:p:h').' && git rev-parse --show-toplevel')
  call system('code -r '.s:repo_path)
  call system('code -r '.expand('%:p'))
endfunction
command! Code call s:open_code()

"--------------------
" vim-sandwich
"--------------------

if dein#tap('vim-auto-save')
  let g:auto_save = 1
endif

""--------------------
"" setting ここまで
""--------------------










"-----------------------
" 表示系
"-----------------------
" let g:loaded_matchparen = 1

augroup vimrchighlight
  autocmd!
  autocmd BufEnter * if 10000 < line('$') | syntax clear | endif
augroup END

function! s:get_syn_id(transparent)
  let synid = synID(line("."), col("."), 1)
  if a:transparent
    return synIDtrans(synid)
  else
    return synid
  endif
endfunction
function! s:get_syn_attr(synid)
  let name = synIDattr(a:synid, "name")
  let ctermfg = synIDattr(a:synid, "fg", "cterm")
  let ctermbg = synIDattr(a:synid, "bg", "cterm")
  let guifg = synIDattr(a:synid, "fg", "gui")
  let guibg = synIDattr(a:synid, "bg", "gui")
  return {
        \ "name": name,
        \ "ctermfg": ctermfg,
        \ "ctermbg": ctermbg,
        \ "guifg": guifg,
        \ "guibg": guibg}
endfunction
function! s:get_syn_info()
  let baseSyn = s:get_syn_attr(s:get_syn_id(0))
  echo "name: " . baseSyn.name .
        \ " ctermfg: " . baseSyn.ctermfg .
        \ " ctermbg: " . baseSyn.ctermbg .
        \ " guifg: " . baseSyn.guifg .
        \ " guibg: " . baseSyn.guibg
  let linkedSyn = s:get_syn_attr(s:get_syn_id(1))
  echo "link to"
  echo "name: " . linkedSyn.name .
        \ " ctermfg: " . linkedSyn.ctermfg .
        \ " ctermbg: " . linkedSyn.ctermbg .
        \ " guifg: " . linkedSyn.guifg .
        \ " guibg: " . linkedSyn.guibg
endfunction
command! SyntaxInfo call s:get_syn_info()
command! SyntaxInfoAll source $VIMRUNTIME/syntax/hitest.vim

set t_Co=256

command! Reload call s:reload()
function! s:reload()
  redraw
  CocRestart

  if dein#tap('lightline.vim')
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()
  endif
endfunction

if &term =~ "xterm"
    set t_RB=[?2004h
    set t_RF=[?2004l
endif

" macOSのダークモード検出
if system("defaults read -g AppleInterfaceStyle 2>/dev/null") =~ '^Dark'
    set background=dark
else
    set background=light
endif

augroup fzfcolorscheme
  autocmd!
  " if (&background == 'dark')
  "   " Override statusline as you like
  "   autocmd ColorScheme * hi! fzf1 ctermfg=161 ctermbg=251
  "   autocmd ColorScheme * hi! fzf2 ctermfg=23 ctermbg=251
  "   autocmd ColorScheme * hi! fzf3 ctermfg=237 ctermbg=251
  " else
  "   autocmd ColorScheme * hi! fzf1 ctermfg=161 ctermbg=7
  "   autocmd ColorScheme * hi! fzf1 ctermfg=23 ctermbg=7
  "   autocmd ColorScheme * hi! fzf1 ctermfg=237 ctermbg=7
  " endif
augroup end

set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

augroup mycolorscheme
  autocmd!
  autocmd ColorScheme * hi Normal term=none ctermbg=none guibg=none
augroup END

" let g:python3_host_prog = substitute(system('which python3'),"\n","","")
let g:loaded_python3_provider = 0

if (&background == 'dark')
  " let g:airline_theme="sonokai"
  " colorscheme sonokai

  let g:airline_theme="ayu"
  let g:ayucolor="dark"   " for dark version of theme
  colorscheme ayu
else
  augroup mycolorschemelight
    autocmd!
    " autocmd ColorScheme * hi! link CursorLineNr CursorLine
    " autocmd ColorScheme * hi! link SignColumn CursorLine
    " autocmd ColorScheme * hi! link VertSplit CursorLine
    " autocmd ColorScheme * hi! Cursor guibg=#54b9d0
  augroup END

  let g:airline_theme='one'
  colorscheme one
end

au User LumenLight source ~/.config/nvim/init.vim
au User LumenDark source ~/.config/nvim/init.vim


if dein#tap('vim-better-whitespace')
  let g:better_whitespace_enabled=1
  if (&background == 'dark')
    let g:better_whitespace_ctermcolor='14'
    let g:better_whitespace_guicolor='#3a453e'
  else
    let g:better_whitespace_ctermcolor='4'
    let g:better_whitespace_guicolor='#ABB0B6'
  endif
  " let g:strip_whitespace_on_save=1
  " let g:strip_whitespace_on_save = 1
  " let g:strip_max_file_size = 1000

  let g:better_whitespace_filetypes_blacklist=['diff', 'gitcommit', 'qf', 'help', 'dein', 'denite', 'vaffle', 'defx']
endif

let g:is_bash = 1

set redrawtime=5000
set number
set more
set showmode          " モード表示
set title             " 編集中のファイル名を表示
set ruler             " ルーラーの表示
set showcmd           " 入力中のコマンドをステータスに表示する
set laststatus=2      " ステータスラインを常に表示
set cursorline        " 下線
set nowrap              " 画面幅で折り返す
set list              " 不可視文字表示
" set listchars=tab:>-,trail:-
set listchars=tab:>-
set display=uhex      " 印字不可能文字を16進数で表示
set nf=hex            " 数値インクリメントは10進数か16進数
set splitbelow        " 水平分割時は新しいwindowを下に
set splitright        " 垂直分割時は新しいwindowを右に
set spelllang+=cjk
set pumblend=10
set winblend=10
set fillchars=eob:\   " ファイル末尾以降の行頭は半角スペース
" set iskeyword=@,48-57,_,192-255,#,$,-
set iskeyword+=-,$,#
set clipboard=unnamed,unnamedplus
set isfname-=:
set synmaxcol=200

"------------------------------
" 移動系
"------------------------------
" 現在位置をマーク
if !exists('g:markrement_char')
  let g:markrement_char = [
        \     'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        \     'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
        \ ]
endif
function! s:AutoMarkrement()
  if !exists('b:markrement_pos')
    let b:markrement_pos = 0
  else
    let b:markrement_pos = (b:markrement_pos + 1) % len(g:markrement_char)
  endif
  execute 'mark' g:markrement_char[b:markrement_pos]
  echo 'marked' g:markrement_char[b:markrement_pos]
endfunction

" バッファ読み込み時にマークを初期化
" autocmd MyAutoCmd BufReadPost * delmarks!


"------------------------------
" 行文字
"------------------------------
:command! Nonum :set nonumber
:command! Num :set number

"------------------------------
"検索系
"------------------------------
set wrapscan        " 最後まで検索したら先頭へ戻る
set ignorecase      " 大文字小文字無視
set smartcase       " 大文字ではじめたら大文字小文字無視しない
set incsearch       " インクリメンタルサーチ
set matchpairs+=(:),{:},[:],<:>

nnoremap * /<C-R><C-r><C-w><CR>N

augroup vimrcincsearchhighlight
  autocmd!
  autocmd CmdlineEnter [/\?] :set hlsearch
augroup END

"--------------------------------
"ファイル操作
"--------------------------------
set mouse=
set nofixeol

" autocmd CursorHold * wall
" autocmd CursorHoldI * wall

" augroup checktime
"   autocmd!
"   autocmd InsertLeave,TextChanged * silent! write
"   autocmd FocusGained,BufEnter * :silent! !
" augroup END
set autoread                        " 更新時自動再読込み
set autowrite
set autowriteall
set hidden                          " 編集中でも他のファイルを開けるようにする
set noswapfile                      " スワップファイルを作らない
set nobackup                        " バックアップを取らない
" autocmd BufWritePre * :%s/\s\+$//ge " 保存時に行末の空白を除去する

" 保存時にディレクトリがなければ作成
function! s:auto_mkdir(dir, force) abort " {{{
  if !isdirectory(a:dir) && (a:force || input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
    call mkdir(iconv(a:dir, &enc, &tenc), 'p')
  endif
endfunction " }}}
autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)

" shebang持ちのファイルの保存時に実行権限を付与
autocmd BufWritePost * :call AddExecmod()
function AddExecmod()
  let line = getline(1)
  if strpart(line, 0, 2) == "#!"
    call system("chmod +x ". expand("%"))
  endif
endfunction

" ファイルを開いた際に、前回終了時の行で起動
augroup open_last_row
  autocmd!
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif
augroup END

"backspaceの挙動
set backspace=start,eol,indent

set scrolloff=0
set history=1000
set viminfo=!,'1000,<500,s10,h,f1,%


command! -nargs=? -bang PWD echo expand('%')

command! -nargs=? -complete=dir -bang CD  call s:ChangeCurrentDir('<args>', '<bang>')
function! s:ChangeCurrentDir(directory, bang)
  if a:directory == ''
    lcd %:p:h
  else
    execute 'lcd ' . a:directory
  endif

  if a:bang == ''
    pwd
  endif
endfunction

set cmdwinheight=2


" https://qiita.com/tmsanrinsha/items/6a2e844768568cd937e1
function! ProfileCursorMove() abort
  let profile_file = expand('~/log/vim-profile.log')
  if filereadable(profile_file)
    call delete(profile_file)
  endif

  normal! gg
  normal! zR

  execute 'profile start ' . profile_file
  profile func *
  profile file *

  augroup ProfileCursorMove
    autocmd!
    autocmd CursorHold <buffer> profile pause | q
  augroup END

  for i in range(100)
    call feedkeys('j')
  endfor
endfunction

" paste
if &term =~ "xterm-256color"
  let &t_ti .= "\e[?2004h"
  let &t_te .= "\e[?2004l"
  let &pastetoggle = "\e[201~"

  function! XTermPasteBegin(ret)
    set paste
    return a:ret
  endfunction

  noremap <special> <expr> <Esc>[200~ XTermPasteBegin("0i")
  inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
  cnoremap <special> <Esc>[200~ <nop>
  cnoremap <special> <Esc>[201~ <nop>
endif

" if executable('zenhan')
"   augroup zenhan
"     autocmd!
"     autocmd InsertLeave * :call system('zenhan 0')
"     autocmd CmdlineLeave * :call system('zenhan 0')
"   augroup END
" endif

"--------------------------------
"ターミナル操作
"--------------------------------
tnoremap <Esc> <C-\><C-n>
tnoremap <C-[> <C-\><C-n>
if has('nvim')
  " Neovim 用
  autocmd WinEnter * if &buftype ==# 'terminal' | startinsert | endif
else
  " Vim 用
  autocmd WinEnter * if &buftype ==# 'terminal' | normal i | endif
endif

"---------------
"タブキーの処理
"--------------
if has('persistent_undo')
  set undodir=./.vim.undo,~/.vim.undo
  augroup SaveUndoFile
    autocmd!
    autocmd BufReadPre ~/* setlocal undofile
  augroup END
endif

set expandtab
set tabstop=4
set softtabstop=-1
set shiftwidth=2
set autoindent
set smartindent
set smarttab


augroup vimrcchecktime
  autocmd!
  autocmd WinEnter * checktime
augroup END

" ファイル読み込み時の文字コード検索順
set termencoding=utf-8
set enc=utf-8
set fencs=utf-8,sjis,utf-16,ucs-bom,euc-jp,cp932,iso-2022-jp,ucs-2le,ucs-2
set ffs=unix,mac,dos

"file format
command! Unix :set ff=unix
command! Dos :set ff=dos
command! Mac :set ff=mac

"file enc
command! Sjis :e ++enc=sjis
command! Utf8 :e ++enc=utf8
command! Utf16 :e ++enc=utf16

" augroup MyXML
"   autocmd!
"   autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o>
"   autocmd Filetype html inoremap <buffer> </ </<C-x><C-o>
"   autocmd Filetype vue inoremap <buffer> </ </<C-x><C-o>
" augroup END

" Jq
command! -nargs=? Jq call s:Jq(<f-args>)
function! s:Jq(...)
  if 0 == a:0
    let l:arg = "."
  else
    let l:arg = a:1
  endif
  execute "%! jq \"" . l:arg . "\""
endfunction

let g:alpha_lower = 'abcdefghijklmnopqrstuvwxyz'
let g:alpha_upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
let g:digits = '0123456789'
let g:alpha_all = g:alpha_lower .. g:alpha_upper
let g:alnum = g:alpha_all .. g:digits
" }}}

" {{{ ClearRegs
function! s:clear_regs() abort
  for r in split(g:alnum .. '/', '\zs')
    call setreg(r, [])
  endfor
endfunction
command! ClearRegs call s:clear_regs()

" column
" command! -nargs=? PrettyCsv call s:PrettyCsv(<f-args>)
" function! s:PrettyCsv(...)
"   " execute "%!perl -pe 's/,(\\s+[^,]*)/,\"\\1\"/g;s/,/,	/g;' | column -t -s='	'"
"   execute "%!perl -pe 's/([^,]*\\s+),/\"\\1\",/g;s/,/	,/g;' | column -t -s='	'"
" endfunction

command! -nargs=? UnprettyCsv call s:UnprettyCsv(<f-args>)
function! s:UnprettyCsv(...)
  silent! %s/\v,\s+/,/g
  " silent! %s/\v\s+,/,/g
endfunction

command! -nargs=? PrettyCsv call s:PrettyCsv(<f-args>)
function! s:PrettyCsv(...)
  call s:UnprettyCsv()
  silent execute "%!perl -pe 's/,(\\s+[^,]*)/,\"\\1\"/g;s/,/,	/g;' | column -t -s='	' 2>/dev/null"
  " execute "%!perl -pe 's/([^,]*\\s+),/\"\\1\",/g;s/,/	,/g;' | column -t -s='	' 2>/dev/null"
  " execute "normal \<C-O>"
endfunction

command! -nargs=? Nfc call s:Nfc(<f-args>)
function! s:Nfc(...)
  silent execute "%!/usr/local/bin/nkf -w --ic=UTF8-MAC"
endfunction

" set helplang=en
set helplang=ja,en
set syntax=on
filetype plugin on
filetype indent on
