local M = {}

local wheel_buttons = {
  WheelUp = true,
  WheelDown = true,
  WheelLeft = true,
  WheelRight = true,
}

local function normalize_event(event)
  if type(event) ~= 'table' then
    return event
  end

  local down = event.Down
  if type(down) ~= 'table' then
    return event
  end

  local button = down.button
  if not wheel_buttons[button] then
    return event
  end

  local normalized = {}
  for key, value in pairs(event) do
    if key ~= 'Down' then
      normalized[key] = value
    end
  end

  normalized[button] = { streak = down.streak or 1 }
  return normalized
end

local function clone_binding(binding)
  local copy = {}
  for key, value in pairs(binding) do
    copy[key] = value
  end
  return copy
end

function M.normalize(bindings)
  if type(bindings) ~= 'table' then
    return bindings
  end

  local result = {}
  for index, binding in ipairs(bindings) do
    local copy = clone_binding(binding)
    copy.event = normalize_event(binding.event)
    result[index] = copy
  end

  return result
end

return M
