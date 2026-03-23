-- window_utils_spec.lua
package.path = os.getenv('HOME') .. '/.hammerspoon/?.lua;' .. package.path

local window_utils = require('window_utils')

local function assertEqual(actual, expected, message)
  if actual ~= expected then
    error((message or '値が一致しません') .. string.format(' (actual: %s, expected: %s)', tostring(actual), tostring(expected)))
  end
end

-- 画面全体より2ピクセル程度小さい場合は拡張対象
local frame_with_gap = {x = 0, y = 0, w = 1918, h = 1078}
local screen_frame = {x = 0, y = 0, w = 1920, h = 1080}
assertEqual(window_utils.should_expand_to_screen(frame_with_gap, screen_frame, 1), true, '上下左右に隙間がある場合は拡張対象')

-- 既に十分同じサイズならば拡張不要
local frame_full = {x = 0, y = 0, w = 1920, h = 1080}
assertEqual(window_utils.should_expand_to_screen(frame_full, screen_frame, 1), false, '完全一致なら拡張不要')

print('window_utils_spec: OK')
