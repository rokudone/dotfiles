hs.hotkey.bind({"ctrl"}, "space", function()
  local alacritty = hs.application.find('alacritty')
  if alacritty:isFrontmost() then
    if alacritty then alacritty:hide() end
  else
    hs.application.launchOrFocus("/Applications/Alacritty.app")
  end
end)

hs.hotkey.bind({"cmd", "space"}, "space", function()
  local brave = hs.application.find('brave')
  if brave:isFrontmost() then
    if brave then brave:hide() end
  else
    hs.application.launchOrFocus("/Applications/Brave Browser.app")
  end
end)

hs.hotkey.bind({"alt", "shift"}, "s", function()
  local slack = hs.application.find('slack')
  if not slack or not slack:isFrontmost() then
    hs.application.launchOrFocus("/Applications/Slack.app")
  end
end)

hs.hotkey.bind({"alt", "shift"}, "a", function()
  local arc = hs.application.find('Arc')
  if not arc or not arc:isFrontmost() then
    hs.application.launchOrFocus("/Applications/Arc.app")
  end
end)

hs.hotkey.bind({"alt", "shift"}, "d", function()
  local obsidian = hs.application.find('Obsidian')
  if not obsidian or not obsidian:isFrontmost() then
    hs.application.launchOrFocus("/Applications/Obsidian.app")
  end
end)

hs.hotkey.bind({"alt", "shift"}, "t", function()
  local tableplus = hs.application.find('TablePlus')
  if not tableplus or not tableplus:isFrontmost() then
    hs.application.launchOrFocus("/Applications/TablePlus.app")
  end
end)

hs.hotkey.bind({"alt", "shift"}, "r", function()
  hs.reload()
end)
