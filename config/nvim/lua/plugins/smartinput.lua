local M = {}

local fn = vim.fn

local function map_to_trigger(mode, trigger, lhs, rhs)
  fn['smartinput#map_to_trigger'](mode, trigger, lhs, rhs)
end

local function define_rule(rule)
  fn['smartinput#define_rule'](rule)
end

function M.setup()
  map_to_trigger('i', '<Space>', '<Space>', '<Space>')
  define_rule({
    at = '(\%#)',
    ['char'] = '<Space>',
    input = '<Space><Space><Left>',
  })

  define_rule({
    at = '( \%# )',
    ['char'] = '<BS>',
    input = '<Del><BS>',
  })

  define_rule({
    at = '\\s\\+\%#',
    ['char'] = '<CR>',
    input = [[<C-o>:call setline(line('.'), substitute(getline(line('.')), '\s\+$', '', ''))<CR><CR>]],
  })

  map_to_trigger('i', '<Bar>', '<Bar>', '<Bar>')

  local filetypes = { 'rust', 'ruby' }
  define_rule({
    at = '\\%#',
    ['char'] = '<Bar>',
    input = '<Bar><Bar><Left>',
    filetype = filetypes,
  })
  define_rule({
    at = '\\%#|',
    ['char'] = '<Bar>',
    input = '<Right>',
    filetype = filetypes,
  })
  define_rule({
    at = '|\%#|',
    ['char'] = '<BS>',
    input = '<BS><Del>',
    filetype = filetypes,
  })
  define_rule({
    at = '||\%#',
    ['char'] = '<BS>',
    input = '<BS><BS>',
    filetype = filetypes,
  })
  define_rule({
    at = '\\\\%#',
    ['char'] = '<Bar>',
    input = '<Bar>',
    filetype = filetypes,
  })
end

return M
