au! BufRead,BufNewFile *.jbuilder set filetype=ruby

function! s:ensure_undo_ftplugin() abort
  if !exists("b:undo_ftplugin")
    let b:undo_ftplugin = ''
  endif
endfunction

augroup ruby
  autocmd!
  autocmd BufRead, BufNewFile ruby echo 'hoge'
  autocmd BufRead, BufNewFile ruby call s:ensure_undo_ftplugin()
augroup End
