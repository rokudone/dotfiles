local M = {}

local helpers = require('tests.helpers')
local assert_eq = helpers.assert_eq
local assert_truthy = helpers.assert_truthy

local cmp_call_log = {
  cmdline = 0,
}

local root_dir_spy = {
  calls = {},
  return_dir = '/tmp/nvim-lsp-root',
}

local fake_servers = {
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

local expected_mason_packages = {
  'lua-language-server',
  'typescript-language-server',
  'json-lsp',
  'html-lsp',
  'css-lsp',
  'tailwindcss-language-server',
  'ruby-lsp',
  'bash-language-server',
  'rust-analyzer',
  'pyright',
  'yaml-language-server',
}

local function stub_modules()
  local originals = {}
  local preload_originals = {}
  local installed_packages = {}
  local mason_lspconfig_setup_opts

  local function stub(name, value)
    originals[name] = package.loaded[name]
    package.loaded[name] = value
  end

  root_dir_spy.calls = {}

  stub('mason', { setup = function() end })
  stub('mason-lspconfig', {
    setup = function(opts)
      mason_lspconfig_setup_opts = opts
    end,
  })

  cmp_call_log.cmdline = 0

  originals['cmp'] = package.loaded['cmp']
  preload_originals['cmp'] = package.preload['cmp']
  package.preload['cmp'] = function()
    local function noop() end

    local mapping = {
      preset = {
        insert = function()
          return {}
        end,
        cmdline = function()
          return {}
        end,
      },
      complete = noop,
      abort = noop,
      scroll_docs = function()
        return noop
      end,
      confirm = function()
        return noop
      end,
    }

    setmetatable(mapping, {
      __call = function(_, fn, _modes)
        return fn
      end,
    })

    local cmp = {
      mapping = mapping,
      config = {
        sources = function(...)
          local combined = {}
          local idx = 1
          for _, list in ipairs({ ... }) do
            for _, item in ipairs(list) do
              combined[idx] = item
              idx = idx + 1
            end
          end
          return combined
        end,
      },
      visible = function()
        return false
      end,
      select_next_item = noop,
      select_prev_item = noop,
    }

    cmp.setup = setmetatable({}, {
      __call = function(_, _opts)
      end,
    })

    function cmp.setup.cmdline(_, _opts)
      cmp_call_log.cmdline = cmp_call_log.cmdline + 1
    end

    return cmp
  end

  originals['luasnip'] = package.loaded['luasnip']
  preload_originals['luasnip'] = package.preload['luasnip']
  package.preload['luasnip'] = function()
    return {
      config = { setup = function() end },
      expand_or_jumpable = function()
        return false
      end,
      jumpable = function()
        return false
      end,
      lsp_expand = function() end,
    }
  end

  preload_originals['mason-registry'] = package.preload['mason-registry']
  package.preload['mason-registry'] = function()
    return {
      get_package = function(name)
        return {
          is_installed = function()
            return false
          end,
          install = function()
            table.insert(installed_packages, name)
          end,
        }
      end,
    }
  end

  return installed_packages, function()
    for name, value in pairs(originals) do
      package.loaded[name] = value
    end
    for name, value in pairs(preload_originals) do
      package.preload[name] = value
    end
  end, function()
    return mason_lspconfig_setup_opts
  end
end

function M.run()
  package.loaded['plugins.lsp'] = nil
  package.preload['plugins.lsp'] = function()
    return dofile(vim.fn.stdpath('config') .. '/lua/plugins/lsp.lua')
  end

  local installed_packages, restore_modules, get_mason_lspconfig_opts = stub_modules()

  local server_modules = {}
  for _, server in ipairs(fake_servers) do
    local module_name = 'lspconfig.configs.' .. server
    server_modules[server] = package.preload[module_name]
    package.preload[module_name] = function()
      local default_config = { name = server }
      if server == 'yamlls' then
        default_config.root_dir = function(fname)
          table.insert(root_dir_spy.calls, fname)
          return root_dir_spy.return_dir
        end
      end
      return { default_config = default_config }
    end
  end

  local config_calls = {}
  local enable_calls = {}

  local original_config = vim.lsp.config
  local original_enable = vim.lsp.enable

  vim.env.BUNDLE_GEMFILE = nil

  vim.lsp.config = setmetatable({}, {
    __call = function(_, name, opts)
      table.insert(config_calls, { name = name, opts = opts })
      return opts
    end,
  })

  vim.lsp.enable = function(name)
    table.insert(enable_calls, name)
  end

  local plugin = require('plugins.lsp')
  local ok, err = pcall(function()
    plugin.setup()
  end)

  vim.lsp.config = original_config
  vim.lsp.enable = original_enable
  restore_modules()
  for server, mod in pairs(server_modules) do
    package.preload['lspconfig.configs.' .. server] = mod
  end
  package.loaded['plugins.lsp'] = nil

  if vim.env.LSP_SPEC_DEBUG == '1' then
    vim.print('config_calls', config_calls)
  end
  assert_truthy(ok, err)
  assert_eq(#config_calls, #fake_servers, 'each server config should be registered')
  assert_eq(#enable_calls, #fake_servers, 'each server should be enabled')
  for index, server in ipairs(fake_servers) do
    assert_eq(config_calls[index].name, server, 'server order must match defined list')
    assert_truthy(type(config_calls[index].opts.on_attach) == 'function', 'on_attach should be preserved')
  end
  local ruby_lsp_config
  for _, call in ipairs(config_calls) do
    if call.name == 'ruby_lsp' then
      ruby_lsp_config = call.opts
      break
    end
  end
  assert_truthy(ruby_lsp_config, 'ruby-lsp config must exist')
  assert_truthy(ruby_lsp_config.settings, 'ruby-lsp should define settings')
  assert_eq(ruby_lsp_config.cmd[1], 'ruby-lsp', 'ruby-lsp のデフォルトコマンドは ruby-lsp 単体であること')
  assert_truthy(ruby_lsp_config.cmd_env, 'ruby-lsp は Bundler の環境を上書きすること')
  assert_eq(
    ruby_lsp_config.cmd_env.BUNDLE_USER_HOME,
    (vim.env.BUNDLE_USER_HOME or (vim.env.HOME .. '/.bundle')),
    'ruby-lsp の BUNDLE_USER_HOME はホーム配下に固定すること'
  )
  assert_eq(
    ruby_lsp_config.cmd_env.BUNDLE_PATH,
    (vim.env.BUNDLE_USER_HOME or (vim.env.HOME .. '/.bundle')) .. '/ruby-lsp',
    'ruby-lsp の BUNDLE_PATH はホーム配下に固定すること'
  )
  assert_eq(
    ruby_lsp_config.cmd_env.BUNDLE_APP_CONFIG,
    (vim.env.BUNDLE_USER_HOME or (vim.env.HOME .. '/.bundle')) .. '/app-config',
    'ruby-lsp の BUNDLE_APP_CONFIG はホーム配下に固定すること'
  )
  assert_eq(ruby_lsp_config.cmd_env.BUNDLE_IGNORE_CONFIG, '1', 'ruby-lsp はプロジェクトの .bundle/config を無視する設定にすること')
  assert_truthy(ruby_lsp_config.cmd_env.PATH:match('/ruby%-lsp/ruby/3%.2%.0/bin'), 'ruby-lsp 用の bin パスを PATH に含めること')
  assert_truthy(ruby_lsp_config.on_new_config, 'ruby-lsp は on_new_config で環境を上書きすること')
  local original_fs_stat = vim.loop.fs_stat
  vim.loop.fs_stat = function(path)
    if path == root_dir_spy.return_dir .. '/Gemfile' then
      return {}
    end
    return nil
  end
  ruby_lsp_config.on_new_config(ruby_lsp_config, root_dir_spy.return_dir)
  assert_eq(ruby_lsp_config.cmd[1], 'ruby-lsp', 'on_new_config 後もコマンドは ruby-lsp のまま')
  assert_eq(ruby_lsp_config.cmd_env.BUNDLE_GEMFILE, nil, 'on_new_config で BUNDLE_GEMFILE はクリアされること')
  vim.loop.fs_stat = original_fs_stat
  local ruby_settings = ruby_lsp_config.settings.ruby
  assert_truthy(ruby_settings, 'ruby-lsp settings table must exist')
  assert_eq(ruby_settings.rubyVersionManager, 'rbenv', 'ruby-lsp は rbenv を前提とした設定を入れること')
  assert_eq(ruby_settings.format, 'auto', 'ruby-lsp の formatter は auto を利用すること')
  assert_eq(ruby_lsp_config.init_options, nil, 'ruby-lsp は enabledFeatures を個別指定しないこと')
  assert_eq(#installed_packages, #expected_mason_packages, 'all mason packages should be queued for install')
  for index, name in ipairs(expected_mason_packages) do
    assert_eq(installed_packages[index], name, 'mason install order should match expected list')
  end
  local mason_lspconfig_opts = get_mason_lspconfig_opts()
  assert_truthy(mason_lspconfig_opts, 'mason-lspconfig setup should receive opts')
  assert_eq(mason_lspconfig_opts.automatic_enable, false, 'automatic_enable は false でなければならない')
  assert_eq(cmp_call_log.cmdline, 0, 'nvim-cmp のコマンドライン統合は無効化すること')

  local yamlls_config
  for _, call in ipairs(config_calls) do
    if call.name == 'yamlls' then
      yamlls_config = call.opts
      break
    end
  end
  assert_truthy(yamlls_config, 'yamlls config must exist')

  local tmpfile = vim.fn.tempname() .. '.yaml'
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(bufnr, tmpfile)
  local normalized_tmpfile = vim.api.nvim_buf_get_name(bufnr)

  local callback_root
  yamlls_config.root_dir(bufnr, function(root_dir)
    callback_root = root_dir
  end)

  vim.api.nvim_buf_delete(bufnr, { force = true })

  assert_eq(root_dir_spy.calls[1], normalized_tmpfile, 'root_dir にはファイルパス文字列を渡すこと')
  assert_eq(callback_root, root_dir_spy.return_dir, 'root_dir コールバックには計算結果のルートパスを渡すこと')
end

return M
