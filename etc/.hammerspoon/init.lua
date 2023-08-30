-- hs.hotkey.bind({"ctrl"}, "space", function()
--   local alacritty = hs.application.find('alacritty')
--   if alacritty:isFrontmost() then
--     alacritty:hide()
--   else
--     hs.application.launchOrFocus("/Applications/Alacritty.app")
--   end
-- end)

-- hs.hotkey.bind({"ctrl"}, "space", function()
--   local warp = hs.application.find('warp')
--   if warp:isFrontmost() then
--     warp:hide()
--   else
--     hs.application.launchOrFocus("/Applications/Warp.app")
--   end
-- end)


hs.hotkey.bind({"command"}, "space", function()
  local obsidian = hs.application.find('obsidian')
  if obsidian:isFrontmost() then
    obsidian:hide()
  else
    hs.application.launchOrFocus("/Applications/Obsidian.app")
  end
end)

hs.hotkey.bind({"ctrl", "shift"}, "space", function()
  local alacritty = hs.application.find('rubymine')
  if alacritty:isFrontmost() then
    alacritty:hide()
  else
    hs.application.launchOrFocus("/Applications/RubyMine.app")
  end
end)
