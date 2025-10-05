local M = {}
local fn = vim.fn

function M.setup()
  local ok, lazy = pcall(require, 'lazy')
  if not ok then
    vim.notify('lazy.nvim is not available', vim.log.levels.WARN)
    return
  end

  lazy.setup({
    {
      'Shatur/neovim-ayu',
      lazy = false,
      priority = 1000,
      config = function()
        local ok_setup, ayu = pcall(require, 'plugins.ayu')
        if ok_setup then
          ayu.setup()
        end
      end,
    },
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      config = function()
        pcall(require, 'plugins.treesitter')
      end,
    },
    {
      'RRethy/nvim-treesitter-endwise',
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
    },
    {
      'coder/claudecode.nvim',
      config = function()
        local ok_setup, claudecode = pcall(require, 'claudecode')
        if ok_setup then
          claudecode.setup({})
        end
      end,
    },
    {
      'junegunn/fzf',
      build = function()
        local ok, err = pcall(function()
          fn['fzf#install']()
        end)
        if not ok then
          vim.notify('fzf#install failed: ' .. tostring(err), vim.log.levels.WARN)
        end
      end,
    },
    {
      'junegunn/fzf.vim',
      dependencies = { 'junegunn/fzf' },
      config = function()
        local ok_setup, fzf = pcall(require, 'plugins.fzf')
        if ok_setup then
          fzf.setup()
        end
      end,
    },
    {
      'nvim-neo-tree/neo-tree.nvim',
      branch = 'v3.x',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
        'MunifTanjim/nui.nvim',
      },
      config = function()
        local ok_setup, neo_tree = pcall(require, 'plugins.neo_tree')
        if ok_setup then
          neo_tree.setup()
        end
      end,
    },
    {
      'glidenote/memolist.vim',
      config = function()
        local ok_setup, memolist = pcall(require, 'plugins.memolist')
        if ok_setup then
          memolist.setup()
        end
      end,
    },
    {
      'junegunn/vim-easy-align',
      config = function()
        local ok_setup, easy_align = pcall(require, 'plugins.easy_align')
        if ok_setup then
          easy_align.setup()
        end
      end,
    },
    {
      'tyru/caw.vim',
      config = function()
        local ok_setup, caw = pcall(require, 'plugins.caw')
        if ok_setup then
          caw.setup()
        end
      end,
    },
    {
      'haya14busa/incsearch-migemo.vim',
      config = function()
        local ok_setup, incsearch = pcall(require, 'plugins.incsearch_migemo')
        if ok_setup then
          incsearch.setup()
        end
      end,
    },
    {
      'mattn/vim-maketable',
      config = function()
        local ok_setup, maketable = pcall(require, 'plugins.maketable')
        if ok_setup then
          maketable.setup()
        end
      end,
    },
    {
      'ntpeters/vim-better-whitespace',
      config = function()
        local ok_setup, whitespace = pcall(require, 'plugins.better_whitespace')
        if ok_setup then
          whitespace.setup()
        end
      end,
    },
    {
      'machakann/vim-sandwich',
      config = function()
        local ok_setup, sandwich = pcall(require, 'plugins.sandwich')
        if ok_setup then
          sandwich.setup()
        end
      end,
    },
    {
      'easymotion/vim-easymotion',
      config = function()
        local ok_setup, easymotion = pcall(require, 'plugins.easymotion')
        if ok_setup then
          easymotion.setup()
        end
      end,
    },
    {
      'preservim/tagbar',
      config = function()
        local ok_setup, tagbar = pcall(require, 'plugins.tagbar')
        if ok_setup then
          tagbar.setup()
        end
      end,
    },
    {
      'liuchengxu/vista.vim',
      config = function()
        local ok_setup, vista = pcall(require, 'plugins.vista')
        if ok_setup then
          vista.setup()
        end
      end,
    },
    {
      't9md/vim-choosewin',
      config = function()
        local ok_setup, choosewin = pcall(require, 'plugins.choosewin')
        if ok_setup then
          choosewin.setup()
        end
      end,
    },
    {
      'osyo-manga/vim-over',
      config = function()
        local ok_setup, over = pcall(require, 'plugins.over')
        if ok_setup then
          over.setup()
        end
      end,
    },
    {
      'vim-airline/vim-airline',
      dependencies = { 'vim-airline/vim-airline-themes' },
      config = function()
        local ok_setup, airline = pcall(require, 'plugins.airline')
        if ok_setup then
          airline.setup()
        end
      end,
    },
    {
      'tpope/vim-fugitive',
      config = function()
        local ok_setup, fugitive = pcall(require, 'plugins.fugitive')
        if ok_setup then
          fugitive.setup()
        end
      end,
    },
    {
      'tpope/vim-rhubarb',
      dependencies = { 'tpope/vim-fugitive' },
    },
    {
      'airblade/vim-gitgutter',
      config = function()
        local ok_setup, gitgutter = pcall(require, 'plugins.gitgutter')
        if ok_setup then
          gitgutter.setup()
        end
      end,
    },
    {
      'vim-scripts/PDV--phpDocumentor-for-Vim',
      config = function()
        local ok_setup, phpdoc = pcall(require, 'plugins.phpdoc')
        if ok_setup then
          phpdoc.setup()
        end
      end,
    },
    {
      'stephpy/vim-php-cs-fixer',
      config = function()
        local ok_setup, phpcs = pcall(require, 'plugins.php_cs_fixer')
        if ok_setup then
          phpcs.setup()
        end
      end,
    },
    {
      'plasticboy/vim-markdown',
      config = function()
        local ok_setup, markdown = pcall(require, 'plugins.markdown')
        if ok_setup then
          markdown.setup()
        end
      end,
    },
    {
      'iamcco/markdown-preview.nvim',
      build = 'cd app && npm install',
      ft = { 'markdown', 'pandoc.markdown', 'rmd' },
      config = function()
        local ok_setup, mkdp = pcall(require, 'plugins.markdown_preview')
        if ok_setup then
          mkdp.setup()
        end
      end,
    },
    {
      'tyru/open-browser.vim',
      ft = { 'markdown', 'pandoc.markdown', 'rmd' },
    },
    {
      'previm/previm',
      ft = { 'markdown', 'pandoc.markdown', 'rmd' },
      config = function()
        local ok_setup, previm = pcall(require, 'plugins.previm')
        if ok_setup then
          previm.setup()
        end
      end,
    },
    {
      'tpope/vim-rails',
      config = function()
        local ok_setup, rails = pcall(require, 'plugins.rails')
        if ok_setup then
          rails.setup()
        end
      end,
    },
    {
      'pocke/cuculus.vim',
      config = function()
        local ok_setup, cuculus = pcall(require, 'plugins.cuculus')
        if ok_setup then
          cuculus.setup()
        end
      end,
    },
    {
      'kana/vim-smartinput',
      config = function()
        local ok_setup, smartinput = pcall(require, 'plugins.smartinput')
        if ok_setup then
          smartinput.setup()
        end
      end,
    },
    {
      'docteurklein/vim-symfony',
      ft = 'php',
      config = function()
        local ok_setup, symfony = pcall(require, 'plugins.symfony')
        if ok_setup then
          symfony.setup()
        end
      end,
    },
    {
      'rhysd/committia.vim',
      ft = 'gitcommit',
      config = function()
        local ok_setup, committia = pcall(require, 'plugins.committia')
        if ok_setup then
          committia.setup()
        end
      end,
    },
    {
      'habamax/vim-asciidoctor',
      ft = { 'asciidoc', 'adoc' },
      config = function()
        local ok_setup, asciidoctor = pcall(require, 'plugins.asciidoctor')
        if ok_setup then
          asciidoctor.setup()
        end
      end,
    },
    {
      'norcalli/nvim-colorizer.lua',
      config = function()
        local ok_setup, colorizer = pcall(require, 'plugins.colorizer')
        if ok_setup then
          colorizer.setup()
        end
      end,
    },
    {
      '907th/vim-auto-save',
      config = function()
        local ok_setup, autosave = pcall(require, 'plugins.auto_save')
        if ok_setup then
          autosave.setup()
        end
      end,
    },
    {
      'thinca/vim-quickrun',
      config = function()
        local ok_setup, quickrun = pcall(require, 'plugins.quickrun')
        if ok_setup then
          quickrun.setup()
        end
      end,
    },
    {
      'thinca/vim-qfreplace',
      config = function()
        local ok_setup, qfreplace = pcall(require, 'plugins.qfreplace')
        if ok_setup then
          qfreplace.setup()
        end
      end,
    },
    {
      'neovim/nvim-lspconfig',
      dependencies = {
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'hrsh7th/cmp-buffer' },
        { 'hrsh7th/cmp-path' },
        { 'hrsh7th/cmp-cmdline' },
        { 'saadparwaiz1/cmp_luasnip' },
        { 'L3MON4D3/LuaSnip' },
        { 'rafamadriz/friendly-snippets' },
      },
      config = function()
        local ok_setup, lsp = pcall(require, 'plugins.lsp')
        if ok_setup then
          lsp.setup()
        end
      end,
    },
  }, {
    change_detection = { enabled = false },
    rocks = {
      enabled = false,
      hererocks = false,
    },
  })
end

return M
