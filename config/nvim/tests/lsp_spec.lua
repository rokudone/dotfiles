local M = {}

local helpers = require('tests.helpers')
local assert_eq = helpers.assert_eq
local assert_truthy = helpers.assert_truthy

local fake_servers = {
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

local expected_mason_packages = {
  'lua-language-server',
  'typescript-language-server',
  'json-lsp',
  'html-lsp',
  'css-lsp',
  'tailwindcss-language-server',
  'ruby-lsp',
  'bash-language-server',
  'gopls',
  'rust-analyzer',
  'pyright',
  'yaml-language-server',
}

local function stub_modules()
  local originals = {}
  local preload_originals = {}
  local installed_packages = {}

  local function stub(name, value)
    originals[name] = package.loaded[name]
    package.loaded[name] = value
  end

  stub('mason', { setup = function() end })
  stub('mason-lspconfig', { setup = function() end })

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
  end
end

function M.run()
  package.loaded['plugins.lsp'] = nil
  package.preload['plugins.lsp'] = function()
    return dofile(vim.fn.stdpath('config') .. '/lua/plugins/lsp.lua')
  end

  local installed_packages, restore_modules = stub_modules()

  local server_modules = {}
  for _, server in ipairs(fake_servers) do
    server_modules[server] = package.preload['lspconfig.configs.' .. server]
    package.preload['lspconfig.configs.' .. server] = function()
      return { default_config = { name = server } }
    end
  end

  local config_calls = {}
  local enable_calls = {}

  local original_config = vim.lsp.config
  local original_enable = vim.lsp.enable

  vim.lsp.config = setmetatable({}, {
    __call = function(_, name, opts)
      table.insert(config_calls, { name = name, opts = opts })
      return opts
    end,
  })

  vim.lsp.enable = function(name)
    table.insert(enable_calls, name)
  end

  local ok, err = pcall(function()
    require('plugins.lsp').setup()
  end)

  vim.lsp.config = original_config
  vim.lsp.enable = original_enable
  restore_modules()
  for server, mod in pairs(server_modules) do
    package.preload['lspconfig.configs.' .. server] = mod
  end
  package.loaded['plugins.lsp'] = nil

  assert_truthy(ok, err)
  assert_eq(#config_calls, #fake_servers, 'each server config should be registered')
  assert_eq(#enable_calls, #fake_servers, 'each server should be enabled')
  for index, server in ipairs(fake_servers) do
    assert_eq(config_calls[index].name, server, 'server order must match defined list')
    assert_truthy(type(config_calls[index].opts.on_attach) == 'function', 'on_attach should be preserved')
  end
  assert_eq(#installed_packages, #expected_mason_packages, 'all mason packages should be queued for install')
  for index, name in ipairs(expected_mason_packages) do
    assert_eq(installed_packages[index], name, 'mason install order should match expected list')
  end
end

return M
