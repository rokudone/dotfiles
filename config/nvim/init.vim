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
set encoding=UTF-8

filetype off
filetype plugin indent off

"----------------------
"dein
"----------------------
let g:dotfiles_path = substitute(system("cd $(dirname ".$MYVIMRC."); git rev-parse --show-toplevel"), "[\n\r]", "", "g")
" let g:dotfiles_path = system("cd $(dirname ".$MYVIMRC."); git rev-parse --show-toplevel")
" let g:dotfiles_path = "~/projects/dotfiles/"
let s:dein_dir = expand('~/.config/nvim.bundle')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim' " dein.vim 本体
let g:dein#install_process_timeout =  600

" deinが入っていなければinstall
if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif

" 設定開始
let &runtimepath = s:dein_repo_dir .",". &runtimepath
let s:toml = '~/.config/nvim/dein.toml'

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir, [$MYVIMRC, s:toml])

  call dein#load_toml(s:toml, {'lazy': 0})

  call dein#end()
  call dein#save_state()
endif

" もし、未インストールものがあったらインストール
if dein#check_install()
  call dein#install()
endif

" :call dein#recache_runtimepath()

"-------------------
" keymap
"-------------------
noremap <Leader> <Nop>
let mapleader = "\<Space>"
nmap <Leader><Leader> <Space>

"esc2回でハイライトを消す
nnoremap <silent> <ESC><ESC> :noh<cr>
"挿入モード便利キー
noremap! <C-P> <Up>
noremap! <C-N> <Down>
noremap! <C-F> <Right>
noremap! <C-B> <Left>
noremap! <C-[> <ESC>

" jump時カーソルを中心にする
nnoremap <C-O> <C-O>zz
nnoremap <C-I> <C-I>zz

"加算
"screenと被るので、<C-A>を<C-Q>へ
nnoremap <C-Q> <C-A>

inoremap <C-C> <C-X>


"command line windowを表示
"swap semicolon and colon
noremap : ;
noremap ; :
set cedit=\<C-f>

" 検索時語句を中心にする
nnoremap * *zz
nnoremap n nzz
nnoremap N Nzz

" exモードを無効に
nnoremap Q <Nop>

" macの辞書を開く
nnoremap g? :!open dict://<cword><CR>

" clipboardにコピーする
vnoremap Y "*y
vnoremap D "*d

"fold
nnoremap zl zo
nnoremap zL zO
nnoremap zh zc
nnoremap zH zC

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

nnoremap <silent> <C-w>1 :<C-u>tabn 1<CR>
nnoremap <silent> <C-w>2 :<C-u>tabn 2<CR>
nnoremap <silent> <C-w>3 :<C-u>tabn 3<CR>
nnoremap <silent> <C-w>4 :<C-u>tabn 4<CR>
nnoremap <silent> <C-w>5 :<C-u>tabn 5<CR>
nnoremap <silent> <C-w>6 :<C-u>tabn 6<CR>
nnoremap <silent> <C-w>7 :<C-u>tabn 7<CR>
nnoremap <silent> <C-w>8 :<C-u>tabn 8<CR>
nnoremap <silent> <C-w>9 :<C-u>tabn 9<CR>
nnoremap <silent> <C-w>0 :<C-u>tabn 10<CR>

nnoremap <silent> <C-w>c :<C-u>tabnew<CR>:tabmove<CR>
nnoremap <silent> <C-w><C-c> :<C-u>tabnew<CR>:tabmove<CR>
nnoremap <silent> <C-w>Q :<C-u>tabclose<CR>

nnoremap <silent> <C-w><bar> :<C-u>vsp<CR>
nnoremap <silent> <C-w>- :<C-u>sp<CR>
nnoremap <silent> <C-w>_ <C-w>-

" nnoremap <C-z> `.zz

" Moving back and forth between lines of same or lower indentation.
" nnoremap <silent> [l :call NextIndent(0, 0, 0, 1)<CR>
" nnoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<CR>
" nnoremap <silent> [L :call NextIndent(0, 0, 1, 1)<CR>
" nnoremap <silent> ]L :call NextIndent(0, 1, 1, 1)<CR>
" vnoremap <silent> [l <Esc>:call NextIndent(0, 0, 0, 1)<CR>m'gv''
" vnoremap <silent> ]l <Esc>:call NextIndent(0, 1, 0, 1)<CR>m'gv''
" vnoremap <silent> [L <Esc>:call NextIndent(0, 0, 1, 1)<CR>m'gv''
" vnoremap <silent> ]L <Esc>:call NextIndent(0, 1, 1, 1)<CR>m'gv''
" onoremap <silent> [l :call NextIndent(0, 0, 0, 1)<CR>
" onoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<CR>
" onoremap <silent> [L :call NextIndent(1, 0, 1, 1)<CR>
" onoremap <silent> ]L :call NextIndent(1, 1, 1, 1)<CR>
"
".edit config
nnoremap <silent> <Leader>es :<C-u>source ~/.config/nvim/init.vim<CR>
nnoremap <silent> <Leader>ev :<C-u>tabnew ~/.config/nvim/init.vim<CR>
nnoremap <silent> <Leader>et :<C-u>tabnew ~/.config/nvim/dein.toml<CR>

" reload file
" nnoremap <silent> <Leader>R :<C-u>e<CR>

" help
" nnoremap          <Leader>H :vert help<space>

" save and quit
nnoremap <silent> <Leader>w :w<CR>
nnoremap <silent> <Leader>W :w sudo:%<CR>
nnoremap <silent> <Leader>q :q<CR>
nnoremap <silent> <Leader>Q :qa!<CR>

" jump same indent
nnoremap <silent> <C-k> k:call search ("^". matchstr (getline (line (".")+ 1), '\(\s*\)') ."\\S", 'b')<CR>^
nnoremap <silent> <C-j> :call search ("^". matchstr (getline (line (".")), '\(\s*\)') ."\\S")<CR>^

if dein#tap('defx.nvim')
  nnoremap <silent> <C-e> :Defx -split=vertical -winwidth=60 -direction=topleft `expand('%:p:h')` -search=`expand('%:p')` <CR>
endif

if dein#tap('fzf.vim')
  " map <Leader>f [fzf]
  nnoremap <silent> <Leader>f :<C-u>GFiles<CR>
  nnoremap <silent> <Leader>F :<C-u>Files<CR>
  nnoremap <silent> <Leader>ee :<C-u>Dotfiles<CR>
  nnoremap <silent> <Leader>u :<C-u>Buffers<CR>
  nnoremap <silent> <Leader>m :<C-u>Marks<CR>
  " nnoremap <silent> <Leader>b :<C-u>LoadedBuffers<CR>
  " nnoremap          <Leader>a :<C-u>Ag<Space>
  nnoremap          <Leader>a :<C-u>Rg<Space>
  nnoremap <silent> <Leader>/ :<C-u>Lines<CR>
  nnoremap <silent> <Leader>? :<C-u>BLines<CR>
  nnoremap <silent> <Leader>h :<C-u>History<CR>
  nnoremap <silent> <Leader>H :<C-u>Helptags<CR>
  nnoremap <silent> <Leader>t :call fzf#vim#tags(expand('<cword>'))<CR>
  nnoremap <silent> <Leader>T :<C-u>Tags<CR>
  nnoremap <silent> <Leader>j :<C-u>Jump<CR>
endif

if dein#tap('coc.nvim')

  " ポップアップメニュー
  " 補完モードのコマンド(|popupmenu-keys| を参照)
  " <CR>で補完せず下の行
  " <Tab>で補完 スニペットのジャンプ
  inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

  " inoremap <expr> <CR> pumvisible() ? "\<C-e>" : "\<C-g>u\<CR>"

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  nnoremap <silent> <C-l> :<C-u>Reload<CR>


  " Use `g[` and `g]` to navigate diagnostics
  " エラーのある位置までジャンプ
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)

  " Remap keys for gotos
  " 定義ジャンプ
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gr <Plug>(coc-references)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nnoremap <silent> gD :call <SID>show_documentation()<CR>
  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Introduce function text object
  " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
  xmap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap if <Plug>(coc-funcobj-i)
  omap af <Plug>(coc-funcobj-a)

  " Remap for rename current word
  " リネーム
  nmap <silent> gR <Plug>(coc-rename)
  " nmap gR <Plug>(coc-refactor)

  " Remap for format selected region
  " 整形
  xmap <silent> gF <Plug>(coc-format-selected)
  " nmap <silent> gF <Plug>(coc-format-selected)
  nnoremap <silent> gF :<C-u>Format<CR>

  " 折りたたみ
  nnoremap <silent> gf :<C-u>Fold<CR>

  " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
  " 選択ファイルを関数化したり、別ファイルに書き出したり
  xmap <silent> ga <Plug>(coc-codeaction-selected)
  nmap <silent> ga <Plug>(coc-codeaction-selected)

  " Remap for do codeAction of current line
  " actionのカレント行バージョン
  nmap <silent> gX  <Plug>(coc-codeaction)

  " Fix autofix problem of current line
  " エラーの自動修正
  nmap <silent> gq  <Plug>(coc-fix-current)


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

endif

" --------------------
" vimspector
" --------------------
" if dein#tap('vimspector')
"   nnoremap <F2> :<C-u>call LaunchFileDebug()<CR>
"   nnoremap <S-F2> :<C-u>VimspectorReset<CR>
"   nmap <S-F9>F9 <Plug>VimspectorToggleConditionalBreakpoint
"   nmap <S-F8>F8 <Plug>VimspectorRunToCursor
" endif

if dein#tap('vista.vim')
  nnoremap <silent> <Leader>o :<C-u>Vista coc<CR>
endif


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
  xmap gA <Plug>(EasyAlign)
  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  nmap gA <Plug>(EasyAlign)
endif

if dein#tap('caw.vim')
  " 行の最初の文字の前にコメント文字をトグル
  nmap gc <Plug>(caw:hatpos:toggle)
  nmap gC <Plug>(caw:wrap:toggle)
  vmap gc <Plug>(caw:hatpos:toggle)
  vmap gC <Plug>(caw:wrap:toggle)
endif

if dein#tap('incsearch-migemo.vim')
  nmap <silent> g/ <Plug>(incsearch-migemo-/)
  " nmap g? <Plug>(incsearch-migemo-?)
endif

if dein#tap('vim-rengbang')
  map <Leader>R <Plug>(operator-rengbang)
endif

if dein#tap('vim-over')
  nnoremap <leader>s :<C-u>OverCommandLine<CR>%s/
  vnoremap <leader>s :<C-u>OverCommandLine<CR>'<,'>s/
endif

if dein#tap('vim-easymotion')
  " <Leader>f{char} to move to {char}
  map  f <Plug>(easymotion-fl)
  map  F <Plug>(easymotion-Fl)
  map  t <Plug>(easymotion-tl)
  map  T <Plug>(easymotion-Tl)

  " s{char}{char} to move to {char}{char}
  nmap <Leader>[ <Plug>(easymotion-overwin-f2)/
  vmap <Leader>[ <Plug>(easymotion-bd-f2)

  " Move to line
  map <Leader>l <Plug>(easymotion-bd-jk)
  nmap <Leader>l <Plug>(easymotion-overwin-line)
  " map <Leader>j <Plug>(easymotion-j)
  " map <Leader>k <Plug>(easymotion-k)
endif

if dein#tap('vim-sandwich')
  runtime macros/sandwich/keymap/surround.vim
  xmap S <Nop>
  xmap s <Plug>(operator-sandwich-add)
endif

map <Leader>g [git]
if dein#tap("vim-fugitive")
  nnoremap [git]f :<C-u>GFiles?<CR>
  nnoremap [git]w :Git status<CR>
  nnoremap [git]c :Git commit<CR>
  nnoremap [git]d :Git diff<CR>
  " nnoremap [git]B :Git blame<CR>
  " vnoremap [git]B :Gbrowse<CR>
endif

if dein#tap("blamer.nvim")
  nnoremap [git]B :BlamerToggle<CR>
endif

if dein#tap("agit.vim")
  nnoremap [git]l :Agit<CR>
endif

if dein#tap("vim-merginal")
  nnoremap [git]b :Merginal<CR>
endif

if dein#tap('vim-gitgutter')
  nmap ]h <Plug>(GitGutterNextHunk)
  nmap [h <Plug>(GitGutterPrevHunk)

  nmap [git]p <Plug>(GitGutterPreviewHunk)
  nmap [git]a <Plug>(GitGutterStageHunk)
  nmap [git]r <Plug>(GitGutterUndoHunk)
  nmap [git]t <Plug>(GitGutterLineHighlightsToggle)
endif

if dein#tap('vim-table-mode')
  let g:table_mode_disable_mappings = 1

  let g:table_mode_map_prefix = ""
  " let g:table_mode_corner = "|"
  let g:table_mode_toggle_map = '<C-t>m'

  let g:table_mode_motion_up_map = '<C-k>'
  let g:table_mode_motion_down_map = '<C-j>'
  let g:table_mode_motion_left_map = '<C-h>'
  let g:table_mode_motion_right_map = '<C-l>'

  " 以下ノーマルモード
  let g:table_mode_tableize_map = '<C-t>T'
  let g:table_mode_tableize_d_map = '<C-t>t'
  let g:table_mode_realign_map = '<C-t>r'
  let g:table_mode_delete_row_map = '<C-t>dr'
  let g:table_mode_delete_column_map = '<C-t>dc'
  " let g:table_mode_add_formula_map = '<C-t>fa'
  " let g:table_mode_eval_formula_map = '<C-t>fe'
  let g:table_mode_echo_cell_map = '<C-t>?'
  " let g:table_mode_sort_map = '<C-t>s'
endif

if dein#tap('memolist.vim')
  nnoremap <Leader>mn  :MemoNew<CR>
  nnoremap <Leader>ml  :MemoListFzf<CR>
  nnoremap <Leader>mg  :MemoGrepFzf<SPACE>
endif

if dein#tap('tagbar')
  nnoremap <Leader>O :TagbarToggle<CR>
endif

if dein#tap('yankround.vim')
  nmap p <Plug>(yankround-p)
  xmap p <Plug>(yankround-p)
  nmap P <Plug>(yankround-P)
  nmap gp <Plug>(yankround-gp)
  xmap gp <Plug>(yankround-gp)
  nmap gP <Plug>(yankround-gP)
  nmap <C-p> <Plug>(yankround-prev)
  nmap <C-n> <Plug>(yankround-next)
endif

" --------------------
" Keymap ここまで
" --------------------





" --------------------
" setting ここから
" --------------------

"-----------
" defx
"----------
if dein#tap('defx.nvim')
  autocmd FileType defx call s:defx_my_settings()

  function! s:defx_my_settings() abort

    function! Defx_git_root_dir(context) abort
      let l:path = system('git rev-parse --show-toplevel')
      let l:path = substitute(l:path, "[\n\r]", "", "g")
      call defx#call_action('cd', l:path)
    endfunction

    " Define mappings
    " move cursor
    nnoremap <silent><buffer><expr> j line('.') == line('$') ? 'gg' : 'j'
    nnoremap <silent><buffer><expr> k line('.') == 1 ? 'G': 'k'

    " change directory
    nnoremap <silent><buffer><expr> <CR>
          \ defx#is_directory() ?
          \ defx#do_action('open'):
          \ defx#do_action('multi', ['quit', 'open'])
    nnoremap <silent><buffer><expr> l
          \ defx#is_directory() ?
          \ defx#do_action('open_tree'):
          \ defx#do_action('preview')
    nnoremap <silent><buffer><expr> L
          \ defx#do_action('open_tree', 'recuresive:5'):
    nnoremap <silent><buffer><expr> h
          \ defx#do_action('close_tree')
    nnoremap <silent><buffer><expr> u defx#do_action('cd', ['..'])
    " nnoremap <silent><buffer><expr> <CR>
    "      \ defx#is_directory() ?
    "      \ defx#do_action('open_or_close_tree'):
    "      \ defx#do_action('drop')
    " nnoremap <silent><buffer><expr> l
    "      \ defx#is_directory() ?
    "      \ defx#do_action('open'):
    "      \ defx#do_action('drop')
    nnoremap <silent><buffer><expr> ` defx#do_action('call', 'Defx_git_root_dir')
    nnoremap <silent><buffer><expr> ~ defx#do_action('cd')
    nnoremap <silent><buffer><expr> \ defx#do_action('cd', ['/'])

    " open file
    nnoremap <silent><buffer><expr> s
          \ defx#do_action('multi', ['quit', ['open', 'split']])
    nnoremap <silent><buffer><expr> v
          \ defx#do_action('multi', ['quit', ['open', 'vsplit']])
    nnoremap <silent><buffer><expr> t
          \ defx#do_action('multi', ['quit', ['open', 'tabnew']])
    " nnoremap <silent><buffer><expr> P defx#do_action('open', 'pedit')

    " move file
    nnoremap <silent><buffer><expr> c    defx#do_action('copy')
    nnoremap <silent><buffer><expr> m     defx#do_action('move')
    nnoremap <silent><buffer><expr> p     defx#do_action('paste')

    " edit file
    nnoremap <silent><buffer><expr> o     defx#do_action('new_directory')
    nnoremap <silent><buffer><expr> i     defx#do_action('new_file')
    nnoremap <silent><buffer><expr> d     defx#do_action('remove')
    nnoremap <silent><buffer><expr> r     defx#do_action('rename')

    " select file
    nnoremap <silent><buffer><expr> <c-j> defx#do_action('toggle_select').'j'
    vnoremap <silent><buffer><expr> <c-j> defx#do_action('toggle_select_visual').'j'
    nnoremap <silent><buffer><expr> <c-k> defx#do_action('toggle_select').'k'
    vnoremap <silent><buffer><expr> <c-k> defx#do_action('toggle_select_visual').'k'
    nnoremap <silent><buffer><expr> *     defx#do_action('toggle_select_all')

    " other
    nnoremap <silent><buffer><expr> x     defx#do_action('execute_system')
    nnoremap <silent><buffer><expr> yy    defx#do_action('yank_path')
    nnoremap <silent><buffer><expr> .     defx#do_action('toggle_ignored_files')
    nnoremap <silent><buffer><expr> <C-l> defx#do_action('redraw')
    nnoremap <silent><buffer><expr> q     defx#do_action('quit')
    nnoremap <silent><buffer><expr> cd    defx#do_action('change_vim_cwd')

  endfunction

  command! DeinClean :call dein#check_clean()
endif

"--------------------
" fzf.vim
"--------------------

if dein#tap('fzf.vim')
  set rtp+=/usr/local/opt/fzf,/home/linuxbrew/.linuxbrew/opt/fzf,~/.fzf
  " let g:fzf_command_prefix = 'Fzf'

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
    end
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


  " This is the default extra key bindings
  let g:fzf_action = {
        \ 'enter': function('s:build_quickfix_list'),
        \ 'ctrl-m': 'open',
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit'}

  " Default fzf layout
  " - down / up / left / right
  let g:fzf_layout = { 'down': '40%' }

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

  command! Jump call s:fzf_jump()

  function! s:fzf_statusline()
    " Override statusline as you like
    highlight fzf1 ctermfg=161 ctermbg=251
    highlight fzf2 ctermfg=23 ctermbg=251
    highlight fzf3 ctermfg=237 ctermbg=251
    setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
  endfunction
  autocmd! User FzfStatusLine call <SID>fzf_statusline()

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
      \ 'header':  ['fg', 'Comment'] }
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
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  augroup end

  " Use `:Format` to format current buffer
  command! -nargs=0 Format :call CocAction('format')

  " Use `:Fold` to fold current buffer
  command! -nargs=? Fold :call CocAction('fold', <f-args>)

  " fold
  " manual 手動で折畳を定義する
  " indent インデントの数を折畳のレベル(深さ)とする
  " expr 折畳を定義する式を指定する
  " syntax 構文強調により折畳を定義する
  " diff 変更されていないテキストを折畳対象とする
  " marker テキスト中の印で折畳を定義する
  set foldlevel=1

  " use `:OR` for organize import of current buffer
  command! -nargs=0 OR  :call CocAction('runCommand', 'editor.action.organizeImport')

  " Add status line support, for integration with other plugin, checkout `:h coc-status`
  set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

  let g:coc_global_extensions = [
        \ 'coc-lists',
        \ 'coc-marketplace',
        \ 'coc-snippets',
        \ 'coc-html',
        \ 'coc-svg',
        \ 'coc-css',
        \ 'coc-tailwindcss',
        \ 'coc-vetur',
        \ 'coc-tsserver',
        \ 'coc-eslint',
        \ 'coc-xml',
        \ 'coc-json',
        \ 'coc-sql',
        \ 'coc-rust-analyzer',
        \ 'coc-diagnostic',
        \ 'coc-go',
        \ 'coc-tabnine',
        \ ]

        "\  'coc-yaml',
        "\  'coc-phpls',

endif

" " --------------------
" " vimspector
" " --------------------
" if dein#tap('vimspector')
"   let g:vimspector_base_dir=expand( '$HOME/.config/vimspector-config' )
" 
"   let g:vimspector_install_gadgets = [
"        \ 'CodeLLDB',
"        \ 'vscode-bash-debug',
"        \ 'vscode-node-debug2',
"        \ 'debugger-for-chrome',
"        \ 'vscode-php-debug',
"        \ ]
" 
"   function! LaunchFileDebug()
"     call vimspector#LaunchWithSettings({'configuration': &filetype.'_file'})
"   endfunction
" 
"   let g:vimspector_enable_mappings = 'HUMAN'
"   " let g:vimspector_enable_mappings = 'VISUAL_STUDIO'
"   " Visual Studio
"   " F5     <Plug>VimspectorContinue              When debugging, continue. Otherwise start debugging.
"   " S-F5   <Plug>VimspectorStop                  Stop debugging.
"   " C-S-F5 <Plug>VimspectorRestart               Restart debugging with the same configuration.
"   " F6     <Plug>VimspectorPause                 Pause debuggee.
"   " F9     <Plug>VimspectorToggleBreakpoint      Toggle line breakpoint on the current line.
"   " S-F9   <Plug>VimspectorAddFunctionBreakpoint Add a function breakpoint for the expression under cursor
"   "
"   " F10    <Plug>VimspectorStepOver              Step Over
"   " F11    <Plug>VimspectorStepInto              Step Into
"   " S-F11  <Plug>VimspectorStepOut               Step out of current function scope
" 
"   " human
"   " F5         <Plug>VimspectorContinue                    When_debugging,_continue._Otherwise_start_debugging.
"   " F3         <Plug>VimspectorStop                        Stop_debugging.
"   " F4         <Plug>VimspectorRestart                     Restart_debugging_with_the_same_configuration.
"   " F6         <Plug>VimspectorPause                       Pause_debuggee.
"   " F9         <Plug>VimspectorToggleBreakpoint            Toggle_line_breakpoint_on_the_current_line.
"   " <leader>F9 <Plug>VimspectorToggleConditionalBreakpoint Toggle_conditional_line_breakpoint_on_the_current_line.
"   "
"   " F8         <Plug>VimspectorAddFunctionBreakpoint       Add_a_function_breakpoint_for_the_expression_under_cursor
"   " <leader>F8 <Plug>VimspectorRunToCursor                 Run_to_Cursor
"   "
"   " F10        <Plug>VimspectorStepOver                    Step_Over
"   " F11        <Plug>VimspectorStepInto                    Step_Into
"   " F12        <Plug>VimspectorStepOut                     Step_out_of_current_function_scope
" 
"   " 以下を打つ
"   " VimspectorInstall
"   " or
"   " VimspectorUpdate
" 
" endif

" --------------------
" vista.vim
" --------------------
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
  " let g:vista_stay_on_open = 1
  " let g:vista_ctags_cmd = {
  "      \ 'haskell': 'hasktags -x -o - -c',
  "      \ }

  " set guifont=RobotoMono\ Nerd\ Font
     "\    'var': "\uf71b",

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

  " let g:vista#renderer#icons = {
  "    \    'func': "\u003e",
  "    \    'function': "\u003e",
  "    \    'functions': "\u003e",
  "    \    'var': "\u003e",
  "    \    'variable': "\u003e",
  "    \    'variables': "\u003e",
  "    \    'const': "\u003e",
  "    \    'constant': "\u003e",
  "    \    'constructor': "\u003e",
  "    \    'method': "\u003e",
  "    \    'package': "\ue612",
  "    \    'packages': "\ue612",
  "    \    'enum': "\u003e",
  "    \    'enummember': "\u003e",
  "    \    'enumerator': "\u003e",
  "    \    'module': "\u003e",
  "    \    'modules': "\u003e",
  "    \    'type': "\u003e",
  "    \    'typedef': "\u003e",
  "    \    'types': "\u003e",
  "    \    'field': "\u003e",
  "    \    'fields': "\u003e",
  "    \    'macro': "\u003e",
  "    \    'macros': "\u003e",
  "    \    'map': "\u003e",
  "    \    'class': "\u003e",
  "    \    'augroup': "\u003e",
  "    \    'struct': "\u003e",
  "    \    'union': "\u003e",
  "    \    'member': "\u003e",
  "    \    'target': "\u003e",
  "    \    'property': "\u003e",
  "    \    'inter003e': "\u003e",
  "    \    'namespace': "\u003e",
  "    \    'subroutine': "\u003e",
  "    \    'implementation': "\u003e",
  "    \    'typeParameter': "\u003e",
  "    \    'default': "\u003e"
  "    \}
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
" auto-ctags
" ------------------
"  auto-ctagsはコマンドで全生成するのためだけに使う
if dein#tap('auto-ctags.vim')
  let g:auto_ctags = 0 "なんかファイルパーミッションがどうので怒られる
  let g:auto_ctags_directory_list = ['.git', '.svn']
  let g:auto_ctags_tags_args = ['--tag-relative=yes', '--recurse=yes', '--sort=yes', '--exclude=node_modules', '--exclude=vendor']
  let g:auto_ctags_set_tags_option = 0
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
  let g:EasyMotion_keys = "awefjioptyusdklzxcvbnmgh;"
  "asdf jiop qwert yukl zxcvbnm gh;"
endif

" a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a
"
if dein#tap('vim-over')
  let g:over_command_line_prompt = ""
endif

" --------------------
" matchit
" --------------------
if dein#tap('matchit')
  let b:match_ignorecase = 1
  nnoremap % %zz
endif

" --------------------
" vim-expand-region
" --------------------
if dein#tap('vim-expand-region')
  " vnoremap j <Plug>(expand_region_expand)
  " vnoremap k <Plug>(expand_region_shrink)
  let g:expand_region_text_objects = {
        \ 'iw'  :0,
        \ 'iW'  :0,
        \ 'i"'  :1,
        \ 'i''' :1,
        \ 'i]'  :1,
        \ 'ib'  :1,
        \ 'iB'  :1,
        \ 'il'  :1,
        \ 'ii'  :1,
        \ 'ip'  :1,
        \ 'if'  :1,
        \ 'ie'  :0,
        \ }
endif

"------------
" airline
"------------
if dein#tap('vim-airline')
  " set ambiwidth=double  " 絵文字>
  set ambiwidth=single  " 絵文字>
  let g:airline_powerline_fonts = 1
  let g:airline_symbols_ascii = 1

  " let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
  " let g:airline#extensions#tabline#formatter = 'default'


  let g:airline#extensions#tabline#enabled = 1

  let g:airline#extensions#tabline#fnamemod = ':t' " タブに表示する名前（fnamemodifyの第二引数）
  let g:airline#extensions#tabline#show_splits = 1 "enable/disable displaying open splits per tab (only when tabs are opened). >
  let g:airline#extensions#tabline#show_buffers = 0 " enable/disable displaying buffers with a single tab
  let g:airline#extensions#tabline#tab_nr_type = 0 " 0でそのタブで開いてるウィンドウ数、1で左のタブから連番
  let g:airline#extensions#tabline#switch_buffers_and_tabs = 1
  let airline#extensions#tabline#current_first = 0

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

  " function! MyTabLine()
  "   let s = ''
  "   for i in range(tabpagenr('$'))
  "     " select the highlighting
  "     if i + 1 == tabpagenr()
  "       let s .= '%#TabLineSel#'
  "       let issel = "v:true"
  "     else
  "       let s .= '%#TabLine#'
  "       let issel = "v:false"
  "     endif
  "     " set the tab page number (for mouse clicks)
  "     let s .= '%' . (i + 1) . 'T'
  "     " the label is made by MyTabLabelFormatter()
  "     let s .= ' %{MyTabLabel(' . (i + 1) . ',' . issel . ')} '
  "   endfor
  "   " after the last tab fill with TabLineFill and reset tab page nr
  "   let s .= '%#TabLineFill#%T'
  "   " " right-align the label to close the current tab page
  "   " if tabpagenr('$') > 1
  "   "   let s .= '%=%#TabLine#%999Xclose'
  "   " endif
  "   return s
  " endfunction
endif

"------------
"lightline
"------------
" if dein#tap('lightline.vim')
"   let g:lightline = {}
"   let g:lightline.enable = {
"        \ 'statusline': 1,
"        \ 'tabline': 1 }
"   let g:lightline.active = {
"        \ 'left': [ [ 'mode', 'paste', 'table', 'jpmode'],
"        \           [ 'file' ],
"        \           [ 'coccurrent' ],
"        \           [ 'vista' ]
"        \         ],
"        \ 'right': [ [ 'lineinfo' ],
"        \          [ 'percent' ],
"        \          [ 'fileformat', 'fileencoding', 'filetype' ] ] }
"   let g:lightline.component_function = {
"        \   'vista': 'NearestMethodOrFunction',
"        \   'table': 'CurrentTableMode',
"        \   'readonly': 'MyReadonly',
"        \   'modified': 'MyModified',
"        \   'file': 'MyFile',
"        \   'coccurrent': 'CocCurrentFunction'
"        \ }
"   "
"   let g:lightline.tabline = {
"        \ 'left': [ [ 'tabs' ] ],
"        \ 'right': [ [ 'close' ] ] }
" 
"   if dein#tap('coc.nvim')
"     function! CocCurrentFunction()
"       let info = get(b:, 'coc_diagnostic_info', {})
"       if empty(info) | return '' | endif
"       let msgs = []
"       if get(info, 'error', 0)
"         call add(msgs, 'E:' . info['error'])
"       endif
"       if get(info, 'warning', 0)
"         call add(msgs, 'W:' . info['warning'])
"       endif
"       if get(info, 'hint', 0)
"         call add(msgs, 'H:' . info['hint'])
"       endif
"       return join(msgs, ' ') . ' ' . get(g:, 'coc_status', '')
"     endfunction
"   else
"     function! CocCurrentFunction()
"       return ""
"     endfunction
"   endif
" 
"   if dein#tap('vim-table-mode')
"     function! CurrentTableMode()
"       " 重い?
"       " if tablemode#IsActive()
"       "   return "TABLE"
"       " else
"       "   return ""
"       " endif
"       return ""
"     endfunction
"   else
"     function! CurrentTableMode()
"       return ""
"     endfunction
"   endif
" 
"   function! MyModified()
"     if &filetype == "help"
"       return ""
"     elseif &modified
"       return "+"
"     elseif &modifiable
"       return ""
"     else
"       return ""
"     endif
"   endfunction
" 
"   function! MyReadonly()
"     if &filetype == "help"
"       return ""
"     elseif &readonly
"       return ""
"     else
"       return ""
"     endif
"   endfunction
" 
"   " function! MyJpMode()
"   "   return IMStatus("JPMODE")
"   " endfunction
"   "
"   " function! MyFile()
"   "   return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
"   "        \ ('' != expand('%') ? ShortenPath() : '[No Name]') .
"   "        \ ('' != MyModified() ? ' ' . MyModified() : '')
"   " endfunction
"   function! MyFile()
"     return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
"         \ ('' != expand('%') ? fnamemodify(expand("%"), ":~:.") : '[No Name]') .
"         \ ('' != MyModified() ? ' ' . MyModified() : '')
"   endfunction
" 
"   function! ShortenPath()
"     let path = substitute(expand('%:h'), $HOME, '~', "g")
"     return substitute(path, '\v/([^/]{1,3})[^/]+', '/\1', "g").'/'.expand('%:t')
"   endfunction
" 
" endif


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
" indentLine
"--------------------
if dein#tap("indentLine")
  let g:indentLine_enabled = 0
  let g:indentLine_char = '¦'
  let g:indentLine_color_term = 236
  let g:indentLine_color_gui = '#708090'
  let g:indentLine_setConceal = 0
  let g:indentLine_fileTypeExclude = ['help', 'dein', 'denite', 'vaffle', 'defx']
endif

"--------------------
" javascript-libraries-syntax.vim
"--------------------

if dein#tap('javascript-libraries-syntax.vim')
  let g:used_javascript_libs = 'jquery, vue'
endif

"--------------------
" vim-vue-plugin
"--------------------
if dein#tap('vim-vue-plugin')
  let g:vim_vue_plugin_config = {
       \'syntax': {
      \   'template': ['html'],
      \   'script': ['typescript', 'javascript'],
      \   'style': ['scss'],
      \   'i18n': ['json'],
      \   'route': 'json',
      \},
      \'full_syntax': [],
      \'initial_indent': [],
      \'attribute': 0,
      \'keyword': 0,
      \'foldexpr': 0,
      \'debug': 0,
      \}
endif

"--------------------
" leafOfTree/vim-matchtag
"--------------------
if dein#tap('vim-matchtag')
  let g:vim_matchtag_enable_by_default = 1
  let g:vim_matchtag_files = '*.html,*.xml,*.vue,*.html.twig'
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

  call smartinput#map_to_trigger('i', '<bar>', '<bar>', '<bar>')
  call smartinput#define_rule({
       \  'at': '^\%#',
       \  'char': '<bar>',
       \  'input': '<c-o>:TableModeEnable<cr><bar><space>',
       \  })

  call smartinput#map_to_trigger('i', '<Bar>', '<Bar>', '<Bar>')
  call smartinput#define_rule({
       \    'at': '\%#',
       \    'char': '<Bar>',
       \    'input': '<Bar><Bar><Left>',
       \    'filetype': ['rust'],
       \ })
  call smartinput#define_rule({
       \    'at': '\%#|',
       \    'char': '<Bar>',
       \    'input': '<Right>',
       \    'filetype': ['rust'],
       \ })
  call smartinput#define_rule({
       \    'at': '|\%#|',
       \    'char': '<BS>',
       \    'input': '<BS><Del>',
       \    'filetype': ['rust'],
       \ })
  call smartinput#define_rule({
       \    'at': '||\%#',
       \    'char': '<BS>',
       \    'input': '<BS><BS>',
       \    'filetype': ['rust'],
       \ })
  call smartinput#define_rule({
       \    'at': '\\\%#',
       \    'char': '<Bar>',
       \    'input': '<Bar>',
       \    'filetype': ['rust'],
       \ })
endif

"--------------------
" vdebug
"--------------------

if dein#tap("vdebug")

  if !exists('g:vdebug_options')
    let g:vdebug_options = {}
  endif

  let g:vdebug_options['port'] = 9000
  let g:vdebug_options['timeout'] = 20
  let g:vdebug_options['server'] = ''
  let g:vdebug_options['on_close'] = 'detach'
  let g:vdebug_options['break_on_open'] = 0
  let g:vdebug_options['ide_key'] = ''
  let g:vdebug_options['debug_window_level'] = 0
  let g:vdebug_options['debug_file_level'] = 0
  let g:vdebug_options['debug_file'] = ''
  let g:vdebug_options['path_maps'] = {'/home/vagrant/projects': $HOME.'/projects'}
  let g:vdebug_options['watch_window_style'] = 'expanded'
  let g:vdebug_options['marker_default'] = '⬦'
  let g:vdebug_options['marker_closed_tree'] = '▸'
  let g:vdebug_options['marker_open_tree'] = '▾'
  let g:vdebug_options['sign_breakpoint'] = '▷'
  let g:vdebug_options['sign_current'] = '▶'
  let g:vdebug_options['sign_disabled'] = '='
  let g:vdebug_options['continuous_mode'] = 1
  let g:vdebug_options['simplified_status'] = 1
  let g:vdebug_options['layout'] = 'vertical'

  let g:vdebug_keymap = {
        \    "step_over" : "<F2>",
        \    "step_into" : "<F3>",
        \    "step_out" : "<F4>",
        \    "run" : "<F5>",
        \    "close" : "<F6>",
        \    "detach" : "<F7>",
        \    "run_to_cursor" : "<F9>",
        \    "set_breakpoint" : "<F10>",
        \    "get_context" : "<F11>",
        \    "eval_under_cursor" : "<F12>",
        \    "eval_visual" : "<Leader>e"
        \}

  augroup vdebug
    autocmd!
    " autocmd ColorScheme * hi DbgBreakptLine term=reverse ctermfg=White ctermbg=Green guifg=#ffffff guibg=#00ff00
    " autocmd ColorScheme * hi DbgBreakptSign term=reverse ctermfg=White ctermbg=Green guifg=#ffffff guibg=#0
    " autocmd ColorScheme * hi clear DbgBreakptLine
    " autocmd ColorScheme * hi clear DbgBreakptSign
  augroup END
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
  function! g:committia_hooks.edit_open(info)
    " Additional settings
    setlocal spell

    " If no commit message, start with insert mode
    if a:info.vcs ==# 'git' && getline(1) ==# ''
      startinsert
    endif

    " Scroll the diff window from insert mode
    " Map <C-n> and <C-p>
    imap <buffer><C-n> <Plug>(committia-scroll-diff-down-half)
    imap <buffer><C-p> <Plug>(committia-scroll-diff-up-half)
  endfunction
endif

"--------------------
" vim-merginal
"--------------------
if dein#tap('vim-merginal')
  let g:merginal_windowWidth = 50
endif

"--------------------
" vim-markdown
"--------------------
if dein#tap('vim-markdown')
  " plasticboy/vim-markdown
  let g:vim_markdown_folding_disabled = 1
  let g:vim_markdown_toc_autofit = 0
  let g:vim_markdown_fenced_languages = ['c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini', 'csharp=cs']
  let g:vim_markdown_new_list_item_indent = 0
  let g:vim_markdown_math = 0
  let g:vim_markdown_frontmatter = 1
  let g:vim_markdown_toml_frontmatter = 0
  let g:vim_markdown_json_frontmatter = 0
  let g:vim_markdown_conceal_code_blocks = 0

  " set nofoldenable

  " gabrielelana/vim-markdown
  " let g:markdown_include_jekyll_support = 1 "disable support for Jekyll files (enabled by default with: 1)
  " let g:markdown_enable_folding = 0 " enable the fold expression markdown#FoldLevelOfLine to fold markdown files. This is disabled by default because it's a huge performance hit even when folding is disabled with the nofoldenable option (disabled by default with: 0)
  " let g:markdown_enable_mappings = 1 " disable default mappings (enabled by default with: 1)
  " let g:markdown_enable_insert_mode_mappings = 0 " disable insert mode mappings (enabled by default with: 1)
  " let g:markdown_enable_insert_mode_leader_mappings = 0 " enable insert mode leader mappings (disabled by default with: 0)
  " let g:markdown_enable_spell_checking = 0 " disable spell checking (enabled by default with: 1)
  " let g:markdown_enable_input_abbreviations = 1 " disable abbreviations for punctuation and emoticons (enabled by default with: 1)
  " let g:markdown_enable_conceal = 0 " enable conceal for italic, bold, inline-code and link text (disabled by default with: 0)
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
    noremap <Leader>A [Adoc]
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
" reireias/vim-cheatsheet
"--------------------
if dein#tap('vim-cheatsheet')
  augroup cheatsheet
    autocmd!
    autocmd BufEnter,BufRead * call s:set_cheatsheet_path()
  augroup END

  function! s:set_cheatsheet_path()
    let filetype = &filetype
    let g:cheatsheet#cheat_file = $HOME.'/.config/nvim/cheatsheet/'.filetype.'.txt'
  endfunction
endif

"--------------------
" memolist
"--------------------
if dein#tap('memolist.vim')
  let g:memolist_memo_suffix = "md"
  let g:memolist_path = $HOME."/posts/"

  " let g:memolist_memo_date = "%Y-%m-%dT%H:%M:%S%z"
  let g:memolist_template_dir_path = $HOME."/.config/nvim/template"

  let g:memolist_prompt_tags = 1
  let g:memolist_prompt_categories = 0
  let g:memolist_fzf = 1
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
" vim-json
"--------------------
if dein#tap('vim-json')
  let g:vim_json_syntax_conceal = 0
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
" php.vim
"--------------------
let g:php_version_id = 70414
let g:php_html_load = 1
let g:php_htmlInStrings = 1


" "--------------------
" " yoink
" "--------------------
" if dein#tap('vim-yoink')
"   let g:yoinkMaxItems = 30
"   let g:yoinkSyncNumberedRegisters = 0
"   let g:yoinkIncludeDeleteOperations = 1
"   " let g:yoinkSavePersistently = 1
"   let g:yoinkAutoFormatPaste = 0
"   let g:yoinkMoveCursorToEndOfPaste = 0
"   let g:yoinkSwapClampAtEnds = 1
"   let g:yoinkIncludeNamedRegisters = 1
"
"   set shada=!,'100,<50,s10,h
" endif

"--------------------
" vim-chrome-devtools
"--------------------
if dein#tap('vim-chrome-devtools')
  let g:ChromeDevTools_host = 'localhost'
  let g:ChromeDevTools_port = 9222
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
"--------------------
" vim-sandwich
"--------------------
if dein#tap('tigris.nvim')
  let g:tigris#enabled = 1
  let g:tigris#on_the_fly_enabled = 1
  let g:tigris#delay = 300
endif

if dein#tap('airsave.vim')
  let g:auto_write = 1
endif

"--------------------
" setting ここまで
"--------------------









let g:python3_host_prog = substitute(system('which python3'),"\n","","")

"-----------------------
" 表示系
"-----------------------
" let g:loaded_matchparen = 1

augroup vimrchighlight
  autocmd!
  autocmd Syntax * if 100000 < line('$') | syntax off | endif
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
command! HighlightInfo call s:get_syn_info()
command! HighlightInfoAll source $VIMRUNTIME/syntax/hitest.vim

" augroup ZenkakuSpace
"   au!
"   au VimEnter,WinEnter,BufRead * let w:m1 = matchadd("ZenkakuSpace", '　')
"   autocmd ColorScheme * hi ZenkakuSpace cterm=underline
" augroup END

set t_Co=256

command! Reload call s:reload()
function! s:reload() abort
  redraw
  CocRestart

  if dein#tap('lightline.vim')
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()
  endif
endfunction

if !has('mac')
  set background=dark
elseif system('defaults read -g AppleInterfaceStyle 2>/dev/null') =~ "Dark"
  set background=dark
else
  set background=light
endif

if (has("termguicolors"))
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

  augroup mycolorscheme
    autocmd!
    autocmd ColorScheme * hi Normal term=none ctermbg=none guibg=none
  augroup END


  if (&background == 'dark')
    let ayucolor="mirage"
    let g:airline_theme='ayu_mirage'
    colorscheme ayu

    " let ayucolor="dark"
    " let g:airline_theme='ayu_dark'
    " colorscheme ayu

    " let g:airline_theme='onedark'
    " colorscheme one
    augroup mycolorschemedark
      " autocmd ColorScheme * hi LineNr ctermbg=224 guibg=#F3F3F3
      autocmd ColorScheme * hi! link SignColumn ColorColumn
      autocmd ColorScheme * hi! link VertSplit ColorColumn
    augroup END
  else
    let ayucolor="light"
    let g:airline_theme='ayu_light'
    colorscheme ayu
    augroup mycolorschemelight
      " autocmd ColorScheme * hi LineNr ctermbg=224 guibg=#F3F3F3
      autocmd ColorScheme * hi! link SignColumn ColorColumn
      autocmd ColorScheme * hi! link VertSplit ColorColumn
      " autocmd ColorScheme * hi VertSplit ctermbg=224 guifg=none guibg=#F3F3F3
    augroup END
  endif
  " ぼんやり
  " let g:gruvbox_contrast_light = 'medium'
  " colorscheme gruvbox

  " ぼんやり
  " colorscheme PaperColor
  " let g:airline_theme='papercolor'
  "
  " colorscheme pencil
  " let g:airline_theme='pencil'
else
  " 256colorの場合
  augroup mycolorscheme
    autocmd!
    "補完メニューの色
    autocmd ColorScheme * hi Pmenu ctermfg=73 ctermbg=16 guifg=#66D9EF guibg=#000000
    autocmd ColorScheme * hi PmenuSel ctermfg=252 ctermbg=23 guibg=#808080
    autocmd ColorScheme * hi PmenuSbar ctermbg=232 guibg=#080808
    autocmd ColorScheme * hi PmenuThumb ctermfg=103 ctermbg=15 guifg=#66D9EF guibg=White

    " 選択
    autocmd ColorScheme * hi Visual ctermbg=238

    "行番号
    autocmd ColorScheme * hi LineNr ctermfg=239
    autocmd ColorScheme * hi CursorLineNr ctermfg=250

    autocmd ColorScheme * hi Delimiter ctermfg=247
    autocmd ColorScheme * hi Comment ctermfg=73
  augroup END

  colorscheme mopkai
endif

" let &colorcolumn="80,".join(range(120,999),",")
" let &colorcolumn=join(range(120,999),",")

if dein#tap('vim-better-whitespace')
  let g:better_whitespace_enabled=1
  if (&background == 'dark')
    let g:better_whitespace_ctermcolor='14'
    let g:better_whitespace_guicolor='#5C6773'
  else
    let g:better_whitespace_ctermcolor='4'
    let g:better_whitespace_guicolor='#ABB0B6'
  endif
  " let g:strip_whitespace_on_save=1
  " let g:strip_whitespace_on_save = 1
  " let g:strip_max_file_size = 1000

  let g:better_whitespace_filetypes_blacklist=['markdown', 'diff', 'gitcommit', 'qf', 'help', 'dein', 'denite', 'vaffle', 'defx']
endif

let g:is_bash = 1

set redrawtime=5000
set signcolumn=yes
set number
set nomore
set showmode          " モード表示
set title             " 編集中のファイル名を表示
set ruler             " ルーラーの表示
set showcmd           " 入力中のコマンドをステータスに表示する
set laststatus=2      " ステータスラインを常に表示
" set cursorline        " 下線
set nowrap              " 画面幅で折り返す
set list              " 不可視文字表示
set listchars=tab:>-  "hannkaku
set display=uhex      " 印字不可能文字を16進数で表示
set nf=hex            " 数値インクリメントは10進数か16進数
set splitbelow        " 水平分割時は新しいwindowを下に
set splitright        " 垂直分割時は新しいwindowを右に
set spelllang+=cjk
set pumblend=15
set fillchars=eob:\   " ファイル末尾以降の行頭は半角スペース
set iskeyword=@,48-57,_,192-255,#,$

" eob:'~'


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

augroup vimrcincsearchhighlight
  autocmd!
  autocmd CmdlineEnter [/\?] :set hlsearch
augroup END

"--------------------------------
"ファイル操作
"--------------------------------
set autowrite
set nofixeol

" autocmd CursorHold * wall
" autocmd CursorHoldI * wall

set autoread                        " 更新時自動再読込み
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
" set shiftwidth=2
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
syntax on
filetype plugin on
filetype indent on
