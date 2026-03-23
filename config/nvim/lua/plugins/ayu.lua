local M = {}

local function notify_failure(err)
  if vim.notify then
    vim.notify('ayu colorscheme を読み込めませんでした: ' .. tostring(err), vim.log.levels.WARN, {
      title = 'plugins.ayu',
    })
  end
end

local function build_comment_overrides(config)
  local fallback_color = '#636A72'
  local comment_color = fallback_color

  local colors_ok, colors = pcall(require, 'ayu.colors')
  if colors_ok and type(colors) == 'table' then
    local generate = colors.generate
    if type(generate) == 'function' then
      pcall(generate, config.mirage)
    end

    if type(colors.comment) == 'string' then
      comment_color = colors.comment
    elseif type(colors.special) == 'string' then
      comment_color = colors.special
    elseif type(colors.fg) == 'string' then
      comment_color = colors.fg
    end
  end

  local function make_highlight()
    return {
      fg = comment_color,
      bg = 'NONE',
      ctermbg = 'NONE',
    }
  end

  local comment = make_highlight()
  comment.italic = true

  local colors_values = {
    fg = 'NONE',
    tag = '#39BAE6',
    entity = '#59C2FF',
    string = '#AAD94C',
  }

  if colors_ok and type(colors) == 'table' then
    if type(colors.fg) == 'string' then colors_values.fg = colors.fg end
    if type(colors.tag) == 'string' then colors_values.tag = colors.tag end
    if type(colors.entity) == 'string' then colors_values.entity = colors.entity end
    if type(colors.string) == 'string' then colors_values.string = colors.string end
  end

  return {
    Comment = comment,
    ['@comment'] = make_highlight(),
    ['@comment.documentation'] = make_highlight(),
    FzfLuaDirPart = make_highlight(),
    -- markdown @markup overrides (ayu未定義のためSpecialにフォールバックするのを防止)
    ['@markup'] = { fg = colors_values.fg },
    ['@markup.raw'] = { fg = colors_values.string },
    ['@markup.raw.block'] = { fg = colors_values.string },
    ['@markup.link'] = { fg = colors_values.entity },
    ['@markup.link.url'] = { fg = colors_values.tag, underline = true },
    ['@markup.link.label'] = { fg = colors_values.entity },
    ['@markup.list'] = { fg = colors_values.tag },
    ['@markup.list.checked'] = { fg = colors_values.string },
    ['@markup.list.unchecked'] = { fg = colors_values.tag },
  }
end

function M.setup()
  local ok, ayu = pcall(require, 'ayu')
  if ok and type(ayu.setup) == 'function' then
    local config = {
      mirage = false,
    }

    config.overrides = function()
      return build_comment_overrides(config)
    end

    ayu.setup(config)
  end

  local success, err = pcall(vim.cmd, 'colorscheme ayu')
  if not success then
    notify_failure(err)
  end
end

return M
