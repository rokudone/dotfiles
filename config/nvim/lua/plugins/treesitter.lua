-- vim.opt.foldmethod     = 'expr'
-- vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
---WORKAROUND
-- vim.api.nvim_create_autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, {
--   group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
--   callback = function()
--     vim.opt.foldmethod     = 'expr'
--     vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
--   end
-- })

local ensure_languages = {
    -- "ada",
    -- "agda",
    -- "arduino",
    -- "astro",
    "awk",
    "bash",
    -- "beancount",
    -- "bibtex",
    -- "blueprint",
    -- "c",
    -- "c_sharp",
    -- "capnp",
    -- "chatito",
    -- "clojure",
    -- "cmake",
    "comment",
    "commonlisp",
    -- "cooklang",
    -- "cpp",
    "css",
    -- "cuda",
    -- "d",
    -- "dart",
    -- "devicetree",
    "diff",
    "dockerfile",
    -- "dot",
    -- "ebnf",
    -- "eex",
    -- "elixir",
    -- "elm",
    -- "elsa",
    -- "elvish",
    -- "embedded_template",
    -- "erlang",
    -- "fennel",
    -- "fish",
    -- "foam",
    -- "fortran",
    -- "fsh",
    -- "func",
    -- "fusion",
    -- "Godot",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    -- "gleam",
    -- "GlimmerandEmber",
    -- "glsl",
    "go",
    -- "GodotResources",
    -- "gomod",
    -- "gosum",
    -- "gowork",
    "graphql",
    -- "hack",
    "haskell",
    -- "hcl",
    -- "heex",
    -- "help",
    -- "hjson",
    -- "hlsl",
    -- "hocon",
    "html",
    -- "htmldjango",
    "http",
    "ini",
    -- "java",
    "javascript",
    "jq",
    "jsdoc",
    "json",
    "json5",
    "jsonc",
    -- "jsonnet",
    -- "julia",
    -- "kdl",
    -- "kotlin",
    -- "lalrpop",
    -- "latex",
    -- "ledger",
    -- "llvm",
    "lua",
    -- "m68k",
    -- "make",
    "markdown",
    "markdown_inline",
    -- "menhir",
    "mermaid",
    "meson",
    -- "nickel",
    -- "ninja",
    -- "nix",
    -- "norg",
    -- "ocaml",
    -- "ocaml_interface",
    -- "ocamllex",
    -- "org",
    -- "pascal",
    "perl",
    "php",
    "phpdoc",
    -- "pioasm",
    -- "PathofExileitemfilter",
    -- "prisma",
    -- "proto",
    -- "pug",
    "python",
    -- "ql",
    -- "qmljs",
    -- "tree-sitter-query",
    -- "r",
    -- "racket",
    -- "rasi",
    "regex",
    -- "rego",
    -- "rnoweb",
    -- "ron",
    -- "rst",
    "ruby",
    "rust",
    "scala",
    "scheme",
    "scss",
    -- "slint",
    -- "smali",
    -- "smithy",
    -- "solidity",
    -- "sparql",
    "sql",
    -- "supercollider",
    -- "surface",
    "svelte",
    -- "swift",
    -- "sxhkdrc",
    -- "t32",
    -- "teal",
    -- "terraform",
    -- "thrift",
    -- "tiger",
    -- "tlaplus",
    "todotxt",
    "toml",
    "tsx",
    -- "turtle",
    -- "twig",
    "typescript",
    -- "v",
    -- "vala",
    -- "verilog",
    -- "vhs",
    "vim",
    "vue",
    -- "wgsl",
    -- "wgsl_bevy",
    "yaml",
    -- "yang",
    -- "zig",
}

local is_headless = #vim.api.nvim_list_uis() == 0

local function first_capture_node(captures, capture_id)
  local capture = captures[capture_id]
  if type(capture) == 'table' then
    return capture[1]
  end
  return capture
end

local function parser_from_markdown_info_string(injection_alias)
  local aliases = {
    ex = 'elixir',
    pl = 'perl',
    sh = 'bash',
    ts = 'typescript',
    uxn = 'uxntal',
  }
  local match = vim.filetype.match({ filename = 'a.' .. injection_alias })
  return match or aliases[injection_alias] or injection_alias
end

local function setup_treesitter_directive_compat()
  if vim.fn.has('nvim-0.12') == 0 then
    return
  end

  local query = require('vim.treesitter.query')
  local opts = { force = true, all = false }

  query.add_directive('set-lang-from-info-string!', function(captures, _, source, directive, metadata)
    local node = first_capture_node(captures, directive[2])
    if not node then
      return
    end

    local injection_alias = vim.treesitter.get_node_text(node, source):lower()
    metadata['injection.language'] = parser_from_markdown_info_string(injection_alias)
  end, opts)

  query.add_directive('set-lang-from-mimetype!', function(captures, _, source, directive, metadata)
    local node = first_capture_node(captures, directive[2])
    if not node then
      return
    end

    local type_attr_value = vim.treesitter.get_node_text(node, source)
    local configured = ({
      importmap = 'json',
      module = 'javascript',
      ['application/ecmascript'] = 'javascript',
      ['text/ecmascript'] = 'javascript',
    })[type_attr_value]

    if configured then
      metadata['injection.language'] = configured
    else
      local parts = vim.split(type_attr_value, '/', {})
      metadata['injection.language'] = parts[#parts]
    end
  end, opts)

  query.add_directive('downcase!', function(captures, _, source, directive, metadata)
    local capture_id = directive[2]
    local node = first_capture_node(captures, capture_id)
    if not node then
      return
    end

    metadata[capture_id] = metadata[capture_id] or {}
    local text = vim.treesitter.get_node_text(node, source, { metadata = metadata[capture_id] }) or ''
    metadata[capture_id].text = string.lower(text)
  end, opts)
end

setup_treesitter_directive_compat()

require'nvim-treesitter.configs'.setup {
  ensure_installed = is_headless and {} or ensure_languages,
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true
    -- enable = false,
  },
  endwise = {
    enable = true
  },
  context_commentstring = {
    enable = true
  },
}
---ENDWORKAROUND
