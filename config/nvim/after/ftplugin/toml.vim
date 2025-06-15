if has('nvim')
  autocmd BufRead Cargo.toml call crates#toggle()
endif
