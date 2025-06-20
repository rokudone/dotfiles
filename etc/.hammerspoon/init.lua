hs.hotkey.bind({"ctrl"}, "space", function()
  local app = hs.application.find('alacritty')
  if app:isFrontmost() then
    if app then app:hide() end
  else
    hs.application.launchOrFocus("/Applications/Alacritty.app")
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

hs.hotkey.bind({}, "pagedown", function()
  local app = hs.application.find('obsidian')
  if app:isFrontmost() then
    if app then
      app:hide()
    end
  else
    hs.application.launchOrFocus("/Applications/Obsidian.app")
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
-- bindAppHotkey('d', 'Dia')
bindAppHotkey('f', 'Floorp')
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
