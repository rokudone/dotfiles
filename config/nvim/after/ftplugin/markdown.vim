set sw=4
let g:previm_open_cmd = 'open -a "Google Chrome"'
let g:gfm_syntax_enable_always = 1
let g:gfm_syntax_emoji_conceal = 1
let g:vim_markdown_conceal = 0


setlocal nofoldenable
setlocal wrap
" setlocal noautoindent
" setlocal nosmartindent
" setlocal nocindent

function! MarkdownToggleCheckbox(type, ...)
  if a:0
    let [lnum1, lnum2] = [a:type, a:1]
  else
    let [lnum1, lnum2] = [line("'["), line("']")]
  endif

  let linenr = lnum1
  while linenr <= lnum2
    let line = getline(linenr)
    if line =~ '\v^\s*[-+*]\s*\[x\]'
      let line = substitute(line, '\v^\s*[-+*]\s\zs\s*\[[^\]]*\]\s*\ze', '', '')
    elseif line =~ '\v^\s*[-+*]\s*\[\s*\]'
      let line = substitute(line, '\v^(\s*[-+*]\s*\[)\s*(\])', '\1'.'x'.'\2', '')
    elseif line =~ '\v^\s*[-+*]\s*'
      let line = substitute(line, '\v^(\s*[-+*]\s*)(.*)', '\1'.'[ ] '.'\2', '')
    endif
    call setline(linenr, line)
    let linenr += 1
  endwhile
endfunction

xnoremap <silent> <buffer> <Bslash>
        \ :<c-u>call MarkdownToggleCheckbox(line("'<"), line("'>"))<cr>
nnoremap <silent> <buffer> <Bslash>
        \ :<c-u>set opfunc=MarkdownToggleCheckbox<bar>exe 'norm! 'v:count1.'g@_'<cr>

nnoremap <silent><buffer> <Leader>o :<C-u>Voom markdown<CR>


setlocal concealcursor=nvic
setlocal conceallevel=0

