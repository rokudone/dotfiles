local M = {}

function M.setup()
  local ok, colorizer = pcall(require, 'colorizer')
  if ok then
    colorizer.setup()
  end
end

return M
