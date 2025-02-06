require('window')
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

-- hs.hotkey.bind({"ctrl"}, "space", function()
--   local iTerm = hs.application.find('iTerm')
--   local cursor = hs.application.find('Cursor')
--   if iTerm:isFrontmost() then
--     if cursor then hs.application.launchOrFocus("/Applications/Cursor.app") end
--     if iTerm then iTerm:hide() end
--   elseif cursor:isFrontmost() then
--     if cursor then cursor:hide() end
--   else
--     if iTerm then hs.application.launchOrFocus("/Applications/iTerm.app") end
--   end
-- end)

hs.hotkey.bind({}, "home", function()
  local edge = hs.application.find('edge')
  if edge:isFrontmost() then
    if edge then
      edge:hide()
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

bindAppHotkey('a', 'Arc')
bindAppHotkey('s', 'Slack')
-- bindAppHotkey('d',)
bindAppHotkey('f', 'Figma')
-- bindAppHotkey('g', '')
-- bindAppHotkey('h', '')
-- bindAppHotkey('j', '')
-- bindAppHotkey('k', '')
-- bindAppHotkey('l', '')


bindAppHotkey('z', 'zoom.us')
-- bindAppHotkey('x', '')
bindAppHotkey('c', 'Cursor')
-- bindAppHotkey('v', '')
-- bindAppHotkey('b', '')
-- bindAppHotkey('n', '')
bindAppHotkey('m', 'YouTube Music')

