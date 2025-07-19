-- 汎用的なアプリトグル関数
local function toggleApp(config)
  local app = nil
  
  -- Bundle IDまたは名前でアプリを検索
  if config.bundleId then
    app = hs.application.get(config.bundleId)
  else
    app = hs.application.find(config.appName)
  end
  
  if app and app:isFrontmost() then
    app:hide()
  else
    hs.application.launchOrFocus(config.appPath)
    -- 起動後のコールバック処理
    if config.afterLaunch then
      hs.timer.doAfter(config.afterLaunchDelay or 0.05, function()
        local launchedApp = config.bundleId and hs.application.get(config.bundleId) or hs.application.find(config.appName)
        if launchedApp and launchedApp:isFrontmost() then
          config.afterLaunch()
        end
      end)
    end
  end
end

-- 便利なヘルパー関数
local function bindAppHotkey(modifiers, key, config)
  hs.hotkey.bind(modifiers, key, function()
    toggleApp(config)
  end)
end

-- アプリケーションのキーバインド設定
bindAppHotkey({"ctrl"}, "space", {
  appName = "WezTerm",
  appPath = "/Applications/WezTerm.app"
})

bindAppHotkey({"ctrl", "shift"}, "space", {
  appName = "Cursor",
  appPath = "/Applications/Cursor.app"
})

-- Dia用の特別なトグル関数
local function toggleDia()
  local app = hs.application.get("company.thebrowser.dia")
  if app and app:isFrontmost() then
    -- System EventsでDiaを非表示にする
    hs.osascript.applescript('tell application "System Events" to set visible of process "Dia" to false')
  else
    hs.application.launchOrFocus("/Applications/Dia.app")
  end
end

hs.hotkey.bind({}, "pageup", toggleDia)

bindAppHotkey({}, "pagedown", {
  appName = "Obsidian",
  appPath = "/Applications/Obsidian.app",
  afterLaunch = function()
    hs.eventtap.keyStroke({"cmd"}, "d")
  end
})

-- Alt+キーのバインド用関数（後方互換性のため残す）
local function bindAltKey(key, appName)
  local appPath = "/Applications/" .. appName .. ".app"
  bindAppHotkey({"alt"}, key, {
    appName = appName,
    appPath = appPath
  })
end


-- Alt + キーのアプリケーションバインド
-- bindAltKey('q', '')
-- bindAltKey('w', '')
bindAltKey('e', 'Microsoft Edge')
-- bindAltKey('r', '')
bindAltKey('t', 'TablePlus')
-- bindAltKey('y', '')
-- bindAltKey('u', '')
-- bindAltKey('i', '')
bindAltKey('o', 'Obsidian')
-- bindAltKey('p', '')

-- bindAltKey('a', 'Arc')
bindAltKey('s', 'Slack')
-- bindAltKey('d', '')
bindAltKey('f', 'Firefox')
-- bindAltKey('g', '')
-- bindAltKey('h', '')
-- bindAltKey('j', '')
-- bindAltKey('k', '')
-- bindAltKey('l', '')

bindAltKey('z', 'zoom.us')
-- bindAltKey('x', 'Xcode')
bindAltKey('c', 'Cursor')
-- bindAltKey('v', '')
-- bindAltKey('b', 'Firefox')
-- bindAltKey('n', '')
bindAltKey('m', 'YouTube Music')
