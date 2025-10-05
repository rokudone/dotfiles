local M = {}

function M.assert_eq(actual, expected, msg)
  if actual ~= expected then
    error((msg or 'assertion failed') .. string.format('\n  expected: %s\n  actual: %s', vim.inspect(expected), vim.inspect(actual)))
  end
end

function M.assert_truthy(value, msg)
  if not value then
    error(msg or 'assertion failed: value is falsy')
  end
end

return M
