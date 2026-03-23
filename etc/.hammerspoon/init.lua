-- CLIからhs.reload()などを実行できるようにする
hs.ipc.cliInstall()

-- 同じモニターの一番左のウィンドウを取得（フォーカスはしない）
local function getLeftmostWindowOnSameScreen(currentWin, excludeApp)
  if not currentWin then return nil end

  local currentScreen = currentWin:screen()
  local candidates = {}

  for _, win in ipairs(hs.window.orderedWindows()) do
    if win:isStandard()
      and not win:isMinimized()
      and win:isVisible()
      and win:screen() == currentScreen
      and win:application() ~= excludeApp
    then
      table.insert(candidates, win)
    end
  end

  if #candidates == 0 then return nil end

  -- x座標でソートして一番左を返す
  table.sort(candidates, function(a, b)
    return a:frame().x < b:frame().x
  end)

  return candidates[1]
end

-- 汎用的なアプリトグル関数
local function toggleApp(config)
  local app = hs.application.find(config.appName)

  if app then
    if app:isFrontmost() then
      app:hide()
    else
      app:activate()
    end
  end
end

-- 便利なヘルパー関数
local function bindAppHotkey(modifiers, key, config)
  hs.hotkey.bind(modifiers, key, function()
    toggleApp(config)
  end)
end

local function bindAltKey(key, appName)
  local appPath = "/Applications/" .. appName .. ".app"
  bindAppHotkey({"alt"}, key, {
    appName = appName,
    appPath = appPath
  })
end

-- アプリケーションのキーバインド設定
bindAppHotkey({"ctrl"}, "space", {
  appName = "cmux",
  appPath = "/Applications/cmux.app",
  focusSameScreenOnHide = true
})

bindAppHotkey({"ctrl", "shift"}, "space", {
  appName = "Ghostty",
  appPath = "/Applications/Ghostty.app"
})

-- Alt + キーのアプリケーションバインド
-- bindAltKey('q', '')t
-- bindAltKey('w', '')
bindAltKey('e', 'Microsoft Edge')
-- bindAltKey('r', '')
bindAltKey('t', 'TablePlus')
-- bindAltKey('y', '')
-- bindAltKey('u', '')
-- bindAltKey('i', '')
bindAltKey('o', 'Obsidian')
-- bindAltKey('p', '')

bindAltKey('a', 'ChatGPT Atlas')
bindAltKey('s', 'Slack')
-- bindAltKey('d', '')
bindAltKey('f', 'Finder')
-- bindAltKey('g', '')
-- bindAltKey('h', '')
-- bindAltKey('j', '')
-- bindAltKey('k', '')
-- bindAltKey('l', '')

bindAltKey('z', 'zoom.us')
-- bindAltKey('x', 'Xcode')
bindAltKey('c', 'Google Chrome')
-- bindAltKey('v', '')
-- bindAltKey('b', 'Firefox')
-- bindAltKey('n', '')
-- bindAltKey('m', 'YouTube Music')

local function collectAppWindows(app)
  if app == nil then
    return {}
  end

  local collected = {}
  for _, win in ipairs(hs.window.orderedWindows()) do
    if win
      and win:application() == app
      and win:isStandard()
      and not win:isMinimized()
      and win:isVisible()
    then
      table.insert(collected, win)
    end
  end

  table.sort(collected, function(a, b)
    return a:id() < b:id()
  end)

  return collected
end

local function cycleAppWindow(direction)
  direction = direction or 1

  local currentWindow = hs.window.focusedWindow()
  if currentWindow == nil then
    return
  end

  local app = currentWindow:application()
  local windows = collectAppWindows(app)
  local count = #windows
  if count < 2 then
    return
  end

  local currentIndex
  for index, win in ipairs(windows) do
    if win == currentWindow then
      currentIndex = index
      break
    end
  end

  if currentIndex == nil then
    currentIndex = 0
  end

  local nextIndex = ((currentIndex - 1 + direction) % count) + 1
  local targetWindow = windows[nextIndex]
  if targetWindow ~= nil then
    hs.timer.doAfter(0, function()
      targetWindow:focus()
      targetWindow:raise()
    end)
  end
end
