-- hs.hotkey.bind({"ctrl"}, "space", function()
--   local app = hs.application.find('alacritty')
--   if app:isFrontmost() then
--     if app then app:hide() end
--   else
--     hs.application.launchOrFocus("/Applications/Alacritty.app")
--   end
-- end)

hs.hotkey.bind({"ctrl"}, "space", function()
  local app = hs.application.find('wezterm')
  if app:isFrontmost() then
    if app then app:hide() end
  else
    hs.application.launchOrFocus("/Applications/WezTerm.app")
  end
end)

hs.hotkey.bind({"ctrl", "shift"}, "space", function()
  local cursor = hs.application.find('cursor')
  if cursor:isFrontmost() then
    if cursor then cursor:hide() end
  else
    hs.application.launchOrFocus("/Applications/Cursor.app")
  end
end)

hs.hotkey.bind({}, "pageup", function()
  local app = hs.application.find('edge')
  if app:isFrontmost() then
    if app then
      app:hide()
    end
  else
    hs.application.launchOrFocus("/Applications/Microsoft Edge.app")
  end
end)

local function bindAppHotkey(key, appName)
  local appPath = "/Applications/" .. appName .. ".app"
  hs.hotkey.bind({"alt"}, key, function()
    local app = hs.application.find(appName)
    if app:isFrontmost() then
      app:hide()
    else
      hs.application.launchOrFocus(appPath)
    end
  end)
end

-- Alacritty hotkey with window sizing and claude-monitor launch
hs.hotkey.bind({}, "pagedown", function()
  local app = hs.application.find('alacritty')
  if app and app:isFrontmost() then
    app:hide()
  else
    hs.application.launchOrFocus("/Applications/Alacritty.app")
    -- Wait for app to launch and then resize window
    hs.timer.doAfter(0.5, function()
      local alacritty = hs.application.find('alacritty')
      if alacritty then
        local win = alacritty:mainWindow()
        if win then
          local screen = win:screen()
          local screenFrame = screen:frame()
          -- Position at top-right corner for 960x540 window
          local x = screenFrame.x + screenFrame.w - 960
          local y = screenFrame.y
          win:setFrame({x = x, y = y, w = 960, h = 540})
        end
      end
    end)
  end
end)

-- Application watcher to launch claude-monitor when Alacritty starts
local alacrittyWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
  if appName == "Alacritty" and eventType == hs.application.watcher.launched then
    -- Check if claude-monitor is already running
    local checkTask = hs.task.new("/bin/bash", function(exitCode, stdOut, stdErr)
      if exitCode == 0 and stdOut ~= "" then
        print("claude-monitor is already running")
      else
        -- Launch claude-monitor script
        print("Starting claude-monitor...")
        local task = hs.task.new("/Users/takuma/bin/claude-monitor", function(exitCode, stdOut, stdErr)
          print("claude-monitor exit code:", exitCode)
          if stdErr ~= "" then
            print("claude-monitor stderr:", stdErr)
          end
        end)
        task:start()
      end
    end, {"-c", "pgrep -f claude-monitor"})
    checkTask:start()
  end
end)
alacrittyWatcher:start()

-- bindAppHotkey('q', '')
-- bindAppHotkey('w', '')
bindAppHotkey('e', 'Microsoft Edge')
-- bindAppHotkey('r', '')
bindAppHotkey('t', 'TablePlus')
-- bindAppHotkey('y', '')
-- bindAppHotkey('u', '')
-- bindAppHotkey('i', '')
bindAppHotkey('o', 'Obsidian')
-- bindAppHotkey('p', '')

-- bindAppHotkey('a', 'Arc')
bindAppHotkey('s', 'Slack')
-- bindAppHotkey('d',)
bindAppHotkey('f', 'Finder')
-- bindAppHotkey('g', '')
-- bindAppHotkey('h', '')
-- bindAppHotkey('j', '')
-- bindAppHotkey('k', '')
-- bindAppHotkey('l', '')


bindAppHotkey('z', 'zoom.us')
bindAppHotkey('x', 'Xcode')
bindAppHotkey('c', 'Cursor')
-- bindAppHotkey('v', '')
bindAppHotkey('b', 'Floorp')
-- bindAppHotkey('n', '')
bindAppHotkey('m', 'YouTube Music')

-- Window Management
local windowManagement = require("window-management")

-- Window positioning hotkeys (Rectangleと同じキーバインド)
hs.hotkey.bind({"alt"}, "left", windowManagement.moveLeft)
hs.hotkey.bind({"alt"}, "right", windowManagement.moveRight)
hs.hotkey.bind({"alt"}, "up", windowManagement.maximize)

