local M = {}

local initialized = false

local servers = {
  'lua_ls',
  'ts_ls',
  'jsonls',
  'html',
  'cssls',
  'tailwindcss',
  'ruby_lsp',
  'bashls',
  'rust_analyzer',
  'pyright',
  'yamlls',
}

local mason_package_map = {
  lua_ls = 'lua-language-server',
  ts_ls = 'typescript-language-server',
  jsonls = 'json-lsp',
  html = 'html-lsp',
  cssls = 'css-lsp',
  tailwindcss = 'tailwindcss-language-server',
  ruby_lsp = 'ruby-lsp',
  bashls = 'bash-language-server',
  rust_analyzer = 'rust-analyzer',
  pyright = 'pyright',
  yamlls = 'yaml-language-server',
}

local function define_command(name, fn, opts)
  if vim.fn.exists(':' .. name) == 0 then
    vim.api.nvim_create_user_command(name, fn, opts or {})
  end
end

local function map_lsp_buffer_key(bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  map('n', 'gd', vim.lsp.buf.definition, 'LSP Definition')
  map('n', 'gD', vim.lsp.buf.type_definition, 'LSP Type Definition')
  map('n', 'gi', vim.lsp.buf.implementation, 'LSP Implementation')
  map('n', 'gR', vim.lsp.buf.rename, 'LSP Rename')
  map('n', 'gF', function()
    vim.lsp.buf.format({ async = true })
  end, 'LSP Format')
  map({ 'n', 'x' }, 'ga', vim.lsp.buf.code_action, 'LSP Code Action')
  map('n', 'gA', vim.lsp.buf.code_action, 'LSP Code Action')
  map('n', 'K', vim.lsp.buf.hover, 'LSP Hover')
  map('n', 'gh', function()
    vim.diagnostic.open_float()
  end, 'Show Diagnostics')

  local function goto_prev_diag()
    vim.diagnostic.goto_prev({ float = true })
  end

  local function goto_next_diag()
    vim.diagnostic.goto_next({ float = true })
  end

  map('n', '[d', goto_prev_diag, 'Prev Diagnostic')
  map('n', ']d', goto_next_diag, 'Next Diagnostic')

  local function references()
    local ok, builtin = pcall(require, 'telescope.builtin')
    if ok and builtin and builtin.lsp_references then
      builtin.lsp_references({})
    else
      vim.lsp.buf.references()
    end
  end

  map('n', 'gr', references, 'LSP References')
end

local function on_attach(_, bufnr)
  map_lsp_buffer_key(bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
end

M.on_attach = on_attach

-- 念のため LspAttach イベントでもキーマップを保証する（on_attach が呼ばれないケースの保険）
local lsp_keymap_group = vim.api.nvim_create_augroup('LspKeymaps', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_keymap_group,
  callback = function(args)
    map_lsp_buffer_key(args.buf)
    vim.bo[args.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
  end,
})

local function setup_cmp()
  local ok_cmp, cmp = pcall(require, 'cmp')
  if not ok_cmp then
    return
  end

  local ok_luasnip, luasnip = pcall(require, 'luasnip')
  if ok_luasnip then
    luasnip.config.setup({})
    pcall(function()
      require('luasnip.loaders.from_vscode').lazy_load()
    end)
  end

  cmp.setup({
    snippet = {
      expand = function(args)
        if ok_luasnip then
          luasnip.lsp_expand(args.body)
        end
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }),
      ['<C-n>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { 'i', 'c' }),
      ['<C-p>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { 'i', 'c' }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif ok_luasnip and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif ok_luasnip and luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'path' },
    }, {
      { name = 'buffer' },
    }),
  })

end

local function setup_diagnostics()
  vim.diagnostic.config({
    severity_sort = true,
    float = { border = 'rounded' },
    update_in_insert = false,
  })

  local signs = {
    Error = 'E',
    Warn = 'W',
    Hint = 'H',
    Info = 'I',
  }

  for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
  end
end

local function setup_commands()
  define_command('Format', function()
    vim.lsp.buf.format({ async = true })
  end, { desc = 'Format current buffer with LSP' })

  define_command('OR', function()
    vim.lsp.buf.code_action({
      apply = true,
      context = { only = { 'source.organizeImports' } },
    })
  end, { desc = 'Organize imports with LSP' })
end

local function adapt_root_dir(config)
  local root_dir = config.root_dir
  if type(root_dir) ~= 'function' then
    return
  end

  local info = debug.getinfo(root_dir, 'u')
  if info and not info.isvararg and info.nparams and info.nparams >= 2 then
    return
  end

  config.root_dir = function(arg1, arg2, ...)
    if type(arg2) == 'function' then
      local bufnr = arg1
      local on_dir = arg2
      local fname = vim.api.nvim_buf_get_name(bufnr)
      local ok, dir = pcall(root_dir, fname)
      if not ok then
        error(dir)
      end
      if dir and dir ~= '' then
        on_dir(dir)
      end
    else
      return root_dir(arg1, arg2, ...)
    end
  end
end

local function setup_lsp()
  local ok_mason, mason = pcall(require, 'mason')
  if ok_mason and type(mason.setup) == 'function' then
    mason.setup()
  end

  local ok_mason_lsp, mason_lspconfig = pcall(require, 'mason-lspconfig')
  if ok_mason_lsp and type(mason_lspconfig.setup) == 'function' then
    mason_lspconfig.setup({
      ensure_installed = servers,
      automatic_installation = false,
      -- mason-lspconfig の automatic_enable 機能は mason で存在するサーバーを
      -- 無条件に enable してしまうため、手動管理している一覧に含まれない
      -- サーバーが勝手に立ち上がるのを防ぐべく明示的に無効化する
      automatic_enable = false,
    })
  end

  local function ensure_mason_packages()
    local ok_registry, registry = pcall(require, 'mason-registry')
    if not ok_registry then
      return
    end

    local function ensure()
      for _, server in ipairs(servers) do
        local package_name = mason_package_map[server] or server
        local ok_package, package = pcall(registry.get_package, package_name)
        if ok_package and package and not package:is_installed() then
          package:install()
        end
      end
    end

    if registry.refresh then
      registry.refresh(ensure)
    else
      ensure()
    end
  end

  ensure_mason_packages()

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp_caps, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if ok_cmp_caps then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

local server_settings = {
    lua_ls = {
      settings = {
        Lua = {
          workspace = { checkThirdParty = false },
          diagnostics = { globals = { 'vim' } },
        },
      },
    },
    ruby_lsp = {
      -- 常にグローバルの ruby-lsp を起動し、プロジェクト側の .bundle/config を無視する
      cmd = { 'ruby-lsp' },
      cmd_env = {
        BUNDLE_USER_HOME = vim.env.BUNDLE_USER_HOME or (vim.env.HOME .. '/.bundle'),
        BUNDLE_PATH = (vim.env.BUNDLE_USER_HOME or (vim.env.HOME .. '/.bundle')) .. '/ruby-lsp',
        BUNDLE_CONFIG = (vim.env.BUNDLE_USER_HOME or (vim.env.HOME .. '/.bundle')) .. '/config',
        BUNDLE_APP_CONFIG = (vim.env.BUNDLE_USER_HOME or (vim.env.HOME .. '/.bundle')) .. '/app-config',
        BUNDLE_IGNORE_CONFIG = '1', -- プロジェクトの .bundle/config を無視して固定パスに入れる
        PATH = ((vim.env.BUNDLE_USER_HOME or (vim.env.HOME .. '/.bundle')) .. '/ruby-lsp/ruby/3.2.0/bin') .. ':' .. vim.env.PATH,
      },
      on_new_config = function(config, _)
        local bundle_home = config.cmd_env and config.cmd_env.BUNDLE_USER_HOME
          or (vim.env.BUNDLE_USER_HOME or (vim.env.HOME .. '/.bundle'))
        config.cmd_env = config.cmd_env or {}
        config.cmd_env.BUNDLE_USER_HOME = bundle_home
        config.cmd_env.BUNDLE_PATH = (config.cmd_env.BUNDLE_PATH or (bundle_home .. '/ruby-lsp'))
        config.cmd_env.BUNDLE_CONFIG = config.cmd_env.BUNDLE_CONFIG or (bundle_home .. '/config')
        config.cmd_env.BUNDLE_APP_CONFIG = config.cmd_env.BUNDLE_APP_CONFIG or (bundle_home .. '/app-config')
        config.cmd_env.BUNDLE_IGNORE_CONFIG = '1'
        config.cmd_env.BUNDLE_GEMFILE = nil
        config.cmd = { 'ruby-lsp' }
      end,
      settings = {
        ruby = {
          rubyVersionManager = 'rbenv',
          format = 'auto',
        },
      },
    },
  }

  for _, server in ipairs(servers) do
    local opts = {
      on_attach = on_attach,
      capabilities = capabilities,
    }

    if server_settings[server] then
      opts = vim.tbl_deep_extend('force', opts, server_settings[server])
    end

    local ok_config_module, config_module = pcall(require, 'lspconfig.configs.' .. server)
    if not ok_config_module or not config_module then
      vim.notify(string.format('LSP server %s is not available', server), vim.log.levels.WARN)
    else
      local default_config = config_module.default_config or {}
      local merged = vim.tbl_deep_extend('force', default_config, opts)
      adapt_root_dir(merged)

      vim.lsp.config(server, merged)
      vim.lsp.enable(server)
    end
  end
end

function M.setup()
  if initialized then
    return
  end
  initialized = true

  setup_cmp()
  setup_diagnostics()
  setup_commands()
  setup_lsp()
end

return M
