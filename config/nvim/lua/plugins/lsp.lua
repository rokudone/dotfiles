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
  'gopls',
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
  gopls = 'gopls',
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

  local function goto_prev_diag()
    vim.diagnostic.goto_prev({ float = true })
  end

  local function goto_next_diag()
    vim.diagnostic.goto_next({ float = true })
  end

  map('n', '[g', goto_prev_diag, 'Prev Diagnostic')
  map('n', ']g', goto_next_diag, 'Next Diagnostic')
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

  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
    },
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' },
    }, {
      { name = 'cmdline' },
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
      cmd_env = { BUNDLE_GEMFILE = vim.env.BUNDLE_GEMFILE },
      init_options = {
        formatter = 'rubocop',
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
      local default_opts = config_module.default_config or {}
      local merged = vim.tbl_deep_extend('force', default_opts, opts)
      if type(merged.root_dir) == 'function' then
        local original_root_dir = merged.root_dir
        merged.root_dir = function(path_or_buf, ...)
          local args = { ... }
          local callback = args[1]
          local path = path_or_buf
          if type(path_or_buf) == 'number' then
            path = vim.api.nvim_buf_get_name(path_or_buf)
          end
          local root = original_root_dir(path)
          if type(callback) == 'function' then
            callback(root)
            return
          end
          return root
        end
      end
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
