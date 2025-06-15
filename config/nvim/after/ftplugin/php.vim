setlocal shiftwidth=2
setlocal iskeyword-=-
setlocal foldmethod=manual

let g:PHP_noArrowMatching = 1
let g:pdv_cfg_Type = "mixed"
let g:pdv_cfg_Package = ""
let g:pdv_cfg_Version = ""
let g:pdv_cfg_Author = ""
let g:pdv_cfg_Copyright = ""
let g:pdv_cfg_License = ""

" if dein#tap('vim-php-cs-fixer')
"   nnoremap <silent><buffer> gF :call PhpCsFixerFixFile()<CR>
"   autocmd BufWritePost *.php silent! call PhpCsFixerFixFile()
" endif

