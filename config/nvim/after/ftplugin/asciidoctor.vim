set sw=2
" for mac
augroup asciidoctor
  nnoremap <silent><buffer> <Leader>r :!open -a Brave\ Browser %<CR>
augroup END

function! OpenWithMarkuPrev()
  echo system('open /Applications/MarkuPrev.app' . ' -n --args ' . shellescape(expand('%:p')))
endfunction
command! MarkuPrev call OpenWithMarkuPrev()
nnoremap <silent><buffer> <Leader>r :<C-U>MarkuPrev<CR>
