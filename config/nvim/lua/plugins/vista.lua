local M = {}

local function set_highlights()
  local group = vim.api.nvim_create_augroup('VistaHighlightLua', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function()
      vim.cmd('hi link VistaParenthesis Operator')
      vim.cmd('hi link VistaScope Keyword')
      vim.cmd('hi link VistaTag Type')
      vim.cmd('hi link VistaKind Constant')
      vim.cmd('hi link VistaScopeKind Define')
      vim.cmd('hi link VistaLineNr LineNr')
      vim.cmd('hi link VistaColon SpecialKey')
      vim.cmd('hi link VistaIcon WarningMsg')
      vim.cmd('hi link VistaArgs Comment')
    end,
  })
end

function M.setup()
  vim.g.vista_icon_indent = { '╰─▸ ', '├─▸ ' }
  vim.g.vista_fold_toggle_icons = { '▼', '▶' }
  vim.g.vista_blink = { 0, 0 }
  vim.g.vista_top_level_blink = { 0, 0 }
  vim.g.vista_highlight_whole_line = 0
  vim.g.vista_echo_cursor = 1
  vim.g.vista_update_on_text_changed = 0
  vim.g.vista_default_executive = 'ctags'
  vim.g.vista_sidebar_width = 50
  vim.g.vista_enable_centering_jump = 1
  vim.g['vista#renderer#enable_icon'] = 1

  vim.g['vista#renderer#icons'] = {
    func = '',
    function = '',
    functions = '',
    var = '',
    variable = '',
    variables = '',
    const = '',
    constant = '',
    constructor = 'ﾙ',
    method = '',
    package = '',
    packages = '',
    enum = '',
    enummember = '',
    enumerator = '',
    module = '',
    modules = '',
    typ = '',
    typedef = '',
    types = '',
    field = 'ﰠ',
    fields = 'ﰠ',
    macro = '煉',
    macros = '煉',
    map = '﮷',
    class = '',
    augroup = '﮷',
    struct = 'פּ',
    union = '',
    member = '',
    target = '',
    property = '襁',
    interface = '',
    namespace = '',
    subroutine = '',
    implementation = '',
    typeParameter = '',
    default = '',
  }

  set_highlights()

  local group = vim.api.nvim_create_augroup('VistaAutoRun', { clear = true })
  vim.api.nvim_create_autocmd('VimEnter', {
    group = group,
    callback = function()
      if vim.fn.exists(':Vista') == 2 then
        vim.cmd('call vista#RunForNearestMethodOrFunction()')
      end
    end,
  })
end

return M
