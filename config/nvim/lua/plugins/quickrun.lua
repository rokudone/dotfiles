local M = {}

function M.setup()
  vim.g.quickrun_config = vim.g.quickrun_config or {}
  vim.g.quickrun_no_default_key_mappings = 1
  vim.g.quickrun_config.scheme = { scheme = { command = 'gosh' } }
  vim.g.quickrun_config.rust = { exec = 'cargo run' }
  vim.g.quickrun_config.typescript = { type = 'typescript/tsc' }
  vim.g.quickrun_config['typescript/tsc'] = {
    command = 'tsc',
    exec = { '%c --target esnext --module commonjs %o %s', 'node %s:r.js' },
    tempfile = '%{tempname()}.ts',
    ['hook/sweep/files'] = { '%S:p:r.js' },
  }

  vim.keymap.set('n', '<Leader>\\', function()
    vim.cmd('w')
    vim.cmd('QuickRun')
  end, { silent = true, desc = 'QuickRun current buffer' })

  local group = vim.api.nvim_create_augroup('QuickRunSettings', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'quickrun',
    command = 'setlocal nofoldenable',
  })
end

return M
