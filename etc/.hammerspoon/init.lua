hs.hotkey.bind({"ctrl"}, "space", function()
  local alacritty = hs.application.find('alacritty')
  if alacritty:isFrontmost() then
    if alacritty then alacritty:hide() end
  else
    hs.application.launchOrFocus("/Applications/Alacritty.app")
  end
end)

-- hs.hotkey.bind({"alt", "shift"}, "space", function()
--   local brave = hs.application.find('brave')
--   if brave:isFrontmost() then
--     if brave then brave:hide() end
--   else
--     hs.application.launchOrFocus("/Applications/Brave Browser.app")
--   end
-- end)
--

hs.hotkey.bind({}, "home", function()
  local edge = hs.application.find('edge')
  if edge:isFrontmost() then
    if edge then edge:hide() end
  else
    hs.application.launchOrFocus("/Applications/Microsoft Edge.app")
  end
end)

local function bindAppHotkey(key, appName)
  local appPath = "/Applications/" .. appName .. ".app"
  hs.hotkey.bind({"alt", "shift"}, key, function()
    local app = hs.application.find(appName)
    if not app or not app:isFrontmost() then
      hs.application.launchOrFocus(appPath)
    end
  end)
end

-- bindAppHotkey('q', '')
-- bindAppHotkey('w', '')
-- bindAppHotkey('e', '')
-- bindAppHotkey('r', '')
-- bindAppHotkey('t', 'TablePlus')
-- bindAppHotkey('y', '')
-- bindAppHotkey('u', '')
-- bindAppHotkey('i', '')
-- bindAppHotkey('o', '')
-- bindAppHotkey('p', '')

bindAppHotkey('a', 'Arc')
bindAppHotkey('s', 'Slack')
-- bindAppHotkey('d', '')
-- bindAppHotkey('f', '')
-- bindAppHotkey('g', '')
-- bindAppHotkey('h', '')
-- bindAppHotkey('j', '')
-- bindAppHotkey('k', '')
-- bindAppHotkey('l', '')


-- bindAppHotkey('z', '')
bindAppHotkey('x', 'Obsidian')
bindAppHotkey('c', 'Cursor')
-- bindAppHotkey('v', '')
-- bindAppHotkey('b', '')
-- bindAppHotkey('n', '')
-- bindAppHotkey('m', '')
