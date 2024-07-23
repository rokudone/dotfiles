hs.hotkey.bind({"ctrl"}, "space", function()
  local alacritty = hs.application.find('alacritty')
  if alacritty:isFrontmost() then
    if alacritty then alacritty:hide() end
  else
    hs.application.launchOrFocus("/Applications/Alacritty.app")
  end
end)

-- hs.hotkey.bind({"ctrl"}, "space", function()
--   local alacritty = hs.application.find('warp')
--   if alacritty:isFrontmost() then
--     if alacritty then alacritty:hide() end
--   else
--     hs.application.launchOrFocus("/Applications/Warp.app")
--   end
-- end)

-- hs.hotkey.bind({"ctrl"}, "space", function()
--   local alacritty = hs.application.find('iterm')
--   if alacritty:isFrontmost() then
--     if alacritty then alacritty:hide() end
--   else
--     hs.application.launchOrFocus("/Applications/iTerm.app")
--   end
-- end)

hs.hotkey.bind({"cmd"}, "space", function()
  local brave = hs.application.find('brave')
  if brave:isFrontmost() then
    if brave then brave:hide() end
  else
    hs.application.launchOrFocus("/Applications/Brave Browser.app")
  end
end)

