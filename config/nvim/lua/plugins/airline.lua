local M = {}

local fn = vim.fn

local function create_section(items)
  return fn['airline#section#create'](items)
end

local function define_tabtitle_formatter()
  vim.cmd([[function! MyTabTitleFormatter(n)
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let bufname = bufname(buflist[winnr - 1])
    let filename = fnamemodify(bufname, ':t:r')
    let extension = fnamemodify(bufname, ':e')
    if extension != ''
      return filename . '.' . extension
    endif
    return filename
  endfunction]])
end

function M.setup()
  vim.opt.ambiwidth = 'double'
  vim.g.airline_powerline_fonts = 1
  vim.g.airline_symbols_ascii = 1
  vim.g.airline_section_b = create_section({})
  vim.g.airline_section_x = create_section({})
  vim.g.airline_section_y = create_section({})
  vim.g.airline_section_z = create_section({})

  vim.g['airline#extensions#tabline#enabled'] = 1
  vim.g.airline_filetype_overrides = {
    ['coc-explorer'] = { 'CoC Explorer', '' },
  }
  vim.g.airline_exclude_filetypes = {
    'dap-repl', 'dapui_console', 'dapui_scopes', 'dapui_breakpoints', 'dapui_stacks', 'dapui_watches',
  }

  vim.g['airline#extensions#tabline#fnamemod'] = ':t'
  vim.g['airline#extensions#tabline#show_splits'] = 1
  vim.g['airline#extensions#tabline#show_buffers'] = 0
  vim.g['airline#extensions#tabline#tab_nr_type'] = 0
  vim.g['airline#extensions#tabline#switch_buffers_and_tabs'] = 1
  vim.g['airline_section_x'] = ''
  vim.g['airline_section_y'] = ''

  define_tabtitle_formatter()
  vim.g['airline#extensions#tabline#tabtitle_formatter'] = 'MyTabTitleFormatter'
end

return M
