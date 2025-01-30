hs.hotkey.bind({"ctrl"}, "space", function()
  local alacritty = hs.application.find('iTerm')
  if alacritty:isFrontmost() then
    if alacritty then alacritty:hide() end
  else
    hs.application.launchOrFocus("/Applications/iTerm.app")
  end
end)

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
-- bindAppHotkey('m', '')
