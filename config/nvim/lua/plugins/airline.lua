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

local function format_lsp_status()
  local ok, clients = pcall(vim.lsp.get_clients, { bufnr = vim.api.nvim_get_current_buf() })
  if not ok or not clients or #clients == 0 then
    return 'LSP: none'
  end

  local labels = {}
  for _, client in ipairs(clients) do
    local state = 'ready'
    if client.initialized == false then
      state = 'init'
    elseif client.is_stopped and client:is_stopped() then
      state = 'stopped'
    end
    table.insert(labels, string.format('%s (%s)', client.name, state))
  end

  local status = vim.lsp.status()
  if status ~= '' then
    return string.format('LSP: %s | %s', table.concat(labels, ', '), status)
  end
  return 'LSP: ' .. table.concat(labels, ', ')
end

function M.lsp_status()
  local ok, value = pcall(format_lsp_status)
  if not ok then
    return ''
  end
  return value
end

local function format_word_and_char_count()
  local ok, counts = pcall(fn.wordcount)
  if not ok or not counts then
    return ''
  end

  local words = counts.words or 0
  local chars = counts.chars or 0

  return string.format('W:%d C:%d', words, chars)
end

function M.word_and_char_count()
  local ok, value = pcall(format_word_and_char_count)
  if not ok then
    return ''
  end
  return value
end

function M.setup()
  -- NOTE: setting ambiwidth=double breaks terminal UIs like fzf inside :terminal
  vim.opt.ambiwidth = 'single'
  vim.g.airline_powerline_fonts = 1
  vim.g.airline_symbols_ascii = 1
  vim.g.airline_section_b = create_section({ '%{expand("%:p")}' })
  vim.g.airline_section_c = create_section({ '%{v:lua.require("plugins.airline").lsp_status()}' })
  vim.g.airline_section_x = create_section({})
  vim.g.airline_section_y = create_section({})
  vim.g['airline#extensions#wordcount#enabled'] = 0

  -- Narrow windows: drop full path first
  vim.g['airline#extensions#default#section_truncate_width'] = {
    b = 120,
  }

  vim.g.airline_section_z = create_section({
    '%{v:lua.require("plugins.airline").word_and_char_count()}',
  })

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
