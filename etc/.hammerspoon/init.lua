-- hs.hotkey.bind({"ctrl"}, "space", function()
--   local iTerm = hs.application.find('iTerm')
--   if iTerm:isFrontmost() then
--     iTerm:hide()
--   else
--     hs.application.launchOrFocus("/Applications/iTerm.app")
--   end
-- end)

hs.hotkey.bind({"ctrl"}, "space", function()
  local alacritty = hs.application.find('alacritty')
  local cursor = hs.application.find('cursor')
  if alacritty:isFrontmost() then
    hs.application.launchOrFocus("/Applications/Cursor.app")
  elseif cursor:isFrontmost() then
    hs.application.launchOrFocus("/Applications/Alacritty.app")
  else
    hs.application.launchOrFocus("/Applications/Alacritty.app")
  end
end)

-- hs.hotkey.bind({"ctrl"}, "space", function()
--   local warp = hs.application.find('warp')
--   if warp:isFrontmost() then
--     warp:hide()
--   else
--     hs.application.launchOrFocus("/Applications/Warp.app")
--   end
-- end)


-- hs.hotkey.bind({"command"}, "space", function()
--   local obsidian = hs.application.find('obsidian')
--   if obsidian:isFrontmost() then
--     obsidian:hide()
--   else
--     hs.application.launchOrFocus("/Applications/Obsidian.app")
--   end
-- end)

-- hs.hotkey.bind({"ctrl", "shift"}, "space", function()
--   local cursor = hs.application.find('cursor')
--   if cursor:isFrontmost() then
--     cursor:hide()
--   else
--     hs.application.launchOrFocus("/Applications/Cursor.app")
--   end
-- end)
