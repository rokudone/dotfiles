local mouse_utils = require('config.wezterm.mouse_utils')

local function assert_equal(actual, expected, message)
  if actual ~= expected then
    error((message or '値が一致しません') .. string.format(' (actual: %s, expected: %s)', tostring(actual), tostring(expected)))
  end
end

local function assert_true(condition, message)
  if not condition then
    error(message or '条件が偽です')
  end
end

local function assert_nil(value, message)
  if value ~= nil then
    error((message or '値は nil であるべきです') .. string.format(' (actual: %s)', tostring(value)))
  end
end

local raw = {
  {
    event = { Down = { button = 'WheelUp', streak = 3 } },
    action = 'up',
  },
  {
    event = { Down = { button = 'Left', streak = 2 } },
    action = 'left',
  },
  {
    event = { Down = { button = 'WheelDown' } },
    action = 'down',
  },
}

local normalized = mouse_utils.normalize(raw)

-- WheelUp は新しい形式に変換される
assert_true(type(normalized[1].event) == 'table', 'event はテーブルでなければなりません')
assert_true(normalized[1].event.WheelUp ~= nil, 'WheelUp キーが必要です')
assert_equal(normalized[1].event.WheelUp.streak, 3, 'streak が引き継がれていません')
assert_nil(normalized[1].event.Down, 'Down キーは削除されるべきです')

-- WheelDown も同様に変換される（streak が指定されていない場合は 1 が入る）
assert_true(normalized[3].event.WheelDown ~= nil, 'WheelDown キーが必要です')
assert_equal(normalized[3].event.WheelDown.streak, 1, 'streak のデフォルトは 1 のはずです')
assert_nil(normalized[3].event.Down, 'Down キーは削除されるべきです (WheelDown)')

-- 通常のボタンは変換されない
assert_true(normalized[2].event.Down ~= nil, '通常のボタンは Down のままです')
assert_equal(normalized[2].event.Down.button, 'Left', 'Left ボタンは維持されるべきです')
assert_equal(normalized[2].event.Down.streak, 2, 'streak は維持されるべきです')

-- 元のデータは破壊されない
assert_true(raw[1].event.Down ~= nil, '元データの Down は変更されません')
assert_equal(raw[1].event.Down.button, 'WheelUp', '元データのボタン名称は保持されるべきです')
assert_true(raw[3].event.Down ~= nil, '元データの Down は変更されません (WheelDown)')

print('wezterm_mouse_utils_spec: OK')
