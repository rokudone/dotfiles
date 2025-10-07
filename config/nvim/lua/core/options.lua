local M = {}

local function append(tbl_option, values)
  for _, value in ipairs(values) do
    tbl_option:append(value)
  end
end

local function remove(tbl_option, values)
  for _, value in ipairs(values) do
    tbl_option:remove(value)
  end
end

function M.setup()
  if vim.tbl_flatten then
    vim.tbl_flatten = function(tbl)
      local result = {}
      local function flatten(list)
        for _, item in ipairs(list) do
          if type(item) == 'table' then
            flatten(item)
          else
            result[#result + 1] = item
          end
        end
      end
      flatten(tbl)
      return result
    end
  end

  vim.g.loaded_perl_provider = 0
  vim.g.loaded_python3_provider = 0
  vim.g.loaded_ruby_provider = 0
  vim.g.is_bash = 1
  vim.g.did_install_default_menus = 1
  vim.g.did_install_syntax_menu = 1
  vim.g.did_indent_on = 1
  vim.g.loaded_2html_plugin = 1
  vim.g.loaded_gzip = 1
  vim.g.loaded_man = 1
  vim.g.loaded_matchparen = 1
  vim.g.loaded_netrwPlugin = 1
  vim.g.loaded_remote_plugins = 1
  vim.g.loaded_shada_plugin = 1
  vim.g.loaded_spellfile_plugin = 1
  vim.g.loaded_tarPlugin = 1
  vim.g.loaded_tutor_mode_plugin = 1
  vim.g.loaded_zipPlugin = 1
  vim.g.skip_loading_mswin = 1

  local opt = vim.opt

  opt.encoding = 'utf-8'
  opt.fileencodings = { 'utf-8', 'sjis', 'utf-16', 'ucs-bom', 'euc-jp', 'cp932', 'iso-2022-jp', 'ucs-2le', 'ucs-2' }
  opt.fileformats = { 'unix', 'dos', 'mac' }

  opt.hidden = true
  opt.backup = false
  opt.writebackup = false
  opt.swapfile = false
  opt.autoread = true
  opt.autowrite = true
  opt.autowriteall = true
  opt.cmdheight = 2
  opt.updatetime = 100
  opt.signcolumn = 'yes'
  opt.shortmess:append('cI')

  opt.redrawtime = 5000
  opt.number = true
  opt.more = true
  opt.showmode = true
  opt.title = true
  opt.ruler = true
  opt.showcmd = true
  opt.laststatus = 2
  opt.cursorline = true
  opt.wrap = false
  opt.list = true
  opt.listchars = { tab = '>-' }
  append(opt.display, { 'uhex' })
  opt.nrformats = { 'hex' }
  opt.splitbelow = true
  opt.splitright = true
  append(opt.spelllang, { 'cjk' })
  opt.pumblend = 10
  opt.winblend = 10
  opt.fillchars = {
    eob = ' ',
    vert = ' ',
    vertleft = ' ',
    vertright = ' ',
    verthoriz = ' ',
  }
  append(opt.iskeyword, { '-', '$', '#' })
  append(opt.clipboard, { 'unnamed', 'unnamedplus' })
  remove(opt.isfname, { ':' })
  opt.synmaxcol = 200
  opt.backspace = { 'start', 'eol', 'indent' }
  opt.scrolloff = 0
  opt.history = 1000
  opt.viminfo = "!,'1000,<500,s10,h,f1,%"
  opt.cmdwinheight = 2
  opt.mouse = 'a'
  opt.fixeol = false

  opt.expandtab = true
  opt.tabstop = 4
  opt.softtabstop = -1
  opt.shiftwidth = 2
  opt.autoindent = true
  opt.smartindent = true
  opt.smarttab = true

  opt.termguicolors = true

  opt.helplang = { 'ja', 'en' }

  opt.undodir = { './.vim.undo', '~/.vim.undo' }

  vim.cmd([[syntax on]])
  vim.cmd([[filetype plugin on]])
  vim.cmd([[filetype indent on]])

end

return M
