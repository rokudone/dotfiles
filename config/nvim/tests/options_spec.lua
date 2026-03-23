local M = {}

local helpers = require('tests.helpers')
local assert_eq = helpers.assert_eq

function M.run()
  local options = require('core.options')
  options.setup()

  assert_eq(vim.o.swapfile, false, 'swapfile should be disabled')
  assert_eq(vim.o.autoread, true, 'autoread should be enabled')
  assert_eq(vim.o.autowrite, true, 'autowrite should be enabled')
  assert_eq(vim.o.autowriteall, true, 'autowriteall should be enabled')
  assert_eq(vim.o.mouse, 'a', 'mouse should be enabled')
  assert_eq(vim.o.fixeol, false, 'fixeol should be disabled')

  local fillchars = vim.opt.fillchars:get()
  assert_eq(fillchars.eob, ' ', 'eob fillchar should be blank')
  assert_eq(fillchars.vert, ' ', 'vertical separator should be hidden')
  assert_eq(fillchars.vertleft, ' ', 'left vertical separator should be hidden')
  assert_eq(fillchars.vertright, ' ', 'right vertical separator should be hidden')
  assert_eq(fillchars.verthoriz, ' ', 'vertical-horizontal separator should be hidden')

  assert_eq(vim.o.mousescroll, 'ver:1,hor:2', 'mouse scroll should move minimal lines')
end

return M
