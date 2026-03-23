local function read_file(path)
  local file, err = io.open(path, 'r')
  if not file then
    error(('ファイルを開けません: %s (%s)'):format(path, err or 'unknown'))
  end

  local content = file:read('*a')
  file:close()
  return content
end

local function assert_contains(haystack, needle, message)
  if not string.find(haystack, needle, 1, true) then
    error(message or ('期待する文字列が見つかりません: %s'):format(needle))
  end
end

local M = {}

function M.run()
  local content = read_file('etc/.tmux.conf')

  assert_contains(
    content,
    'copy-mode -e; send-keys -X -N 1 scroll-up',
    'WheelUp のスクロールが1行単位で行われるべきです'
  )

  assert_contains(
    content,
    'copy-mode -e; send-keys -X -N 1 scroll-down',
    'WheelDown のスクロールが1行単位で行われるべきです'
  )
end

return M
