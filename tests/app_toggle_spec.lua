package.path = os.getenv('HOME') .. '/.hammerspoon/?.lua;' .. package.path

local app_toggle = require('app_toggle')

local function assertEqual(actual, expected, message)
  if actual ~= expected then
    error((message or '値が一致しません') .. string.format(' (actual: %s, expected: %s)', tostring(actual), tostring(expected)))
  end
end

local function assertSequence(actual, expected, message)
  if #actual ~= #expected then
    error((message or '配列の長さが一致しません') .. string.format(' (actual: %d, expected: %d)', #actual, #expected))
  end

  for index = 1, #expected do
    if actual[index] ~= expected[index] then
      error((message or '配列の内容が一致しません') .. string.format(' (index: %d, actual: %s, expected: %s)', index, tostring(actual[index]), tostring(expected[index])))
    end
  end
end

local function fakeApp(options, calls)
  options = options or {}
  calls = calls or {}

  return {
    isFrontmost = function()
      return options.isFrontmost or false
    end,
    hide = function()
      table.insert(calls, 'hide')
    end,
    activate = function(_, allWindows)
      table.insert(calls, string.format('activate:%s', tostring(allWindows)))
    end,
    unhide = function()
      table.insert(calls, 'unhide')
    end,
    __calls = calls
  }
end

do
  local calls = {}
  local app = fakeApp({ isFrontmost = true }, calls)
  local findApp = function()
    return app
  end

  app_toggle.toggle(findApp, { appName = 'Alacritty' })

  assertSequence(calls, { 'hide' }, 'フォアグラウンドでは hide のみを呼び出す')
end

do
  local calls = {}
  local app = fakeApp({ isFrontmost = false }, calls)
  local findApp = function()
    return app
  end

  app_toggle.toggle(findApp, { appName = 'Alacritty' })

  assertSequence(calls, { 'unhide', 'activate:true' }, 'バックグラウンドでは unhide と activate(true) を呼び出す')
end

do
  local calls = {}
  local findApp = function()
    return nil
  end

  app_toggle.toggle(findApp, { appName = 'Alacritty' })

  assertEqual(#calls, 0, 'アプリが見つからない場合は何もしない')
end

print('app_toggle_spec: OK')
