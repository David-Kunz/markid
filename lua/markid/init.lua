local ts = require('nvim-treesitter')
local parsers = require("nvim-treesitter.parsers")
local configs = require("nvim-treesitter.configs")

local namespace = vim.api.nvim_create_namespace("markid")

local get_root = function(parser)
  local tree = parser:parse()[1]
  return tree:root()
end

local get_query = function(lang)
  if lang == "javascript" or lang == "typescript" then
    return vim.treesitter.parse_query(lang, 
    [[
    (identifier) @identifier
    (property_identifier) @identifier
    ]])
  end
  return vim.treesitter.parse_query(lang, 
  [[
  (identifier) @identifier
  ]])
end



function colorizer(colors)
  local idx = 0
  local highlights = {}
  local function next()
    idx = idx + 1
    if idx > #colors then
      idx = 1
    end
    if highlights[idx] == nil then
      local group_name = "markid" .. idx
      vim.highlight.create(group_name, { guifg = colors[idx] })
      highlights[idx] = group_name
    end
    return highlights[idx]
  end
  return next
end


ts.define_modules {
  markid = {
    attach = function(bufnr, lang)
      local config = configs.get_module("markid")

      local query = get_query(lang)
      local parser = parsers.get_parser(bufnr, lang)
      local root = get_root(parser)


      local next_hl = colorizer(config.colors)
      local hl_group_of_identifier = {}

      function highlight_tree(tree, cap_start, cap_end)
        vim.api.nvim_buf_clear_namespace(bufnr, namespace, cap_start, cap_end)
        for id, node in query:iter_captures(tree, bufnr, cap_start, cap_end) do
          local name = query.captures[id]
          local text = vim.treesitter.query.get_node_text(node, bufnr)
          if hl_group_of_identifier[text] == nil then
            hl_group_of_identifier[text] = next_hl()
          end
          local start_row, start_col, end_row, end_col = node:range()
          local range_start = { start_row, start_col }
          local range_end = { end_row, end_col }
          vim.highlight.range(bufnr, namespace, hl_group_of_identifier[text], range_start, range_end)
        end
      end

      highlight_tree(root, 0, -1)

      parser:register_cbs({
        on_changedtree = function(changes, tree)
          for _, change in ipairs(changes) do
            local change_root = tree:root()
            highlight_tree(change_root, change[1], change[3] + 1)
          end
        end
      })
    end,

    detach = function(bufnr)
      vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    end,
    is_supported = function(lang)
      return pcall(vim.treesitter.parse_query, lang, [[ (identifier) @identifier ]])
    end,

    -- default options
    colors = {
      "#bf6060", "#bf9f60", "#bcbf60", "#60bf91", "#60b7bf", "#607cbf", "#7860bf", "#a160bf", "#bf6093"
      -- "#7897C6", "#bec1d4", "#d6bcc0", "#bb7784", "#4a6fd3", "#8595e1", "#b5bbe3", "#e6afb9", "#e07b91", "#784B5E", "#2E7D32", "#8dd593", "#c6dec7", "#ead3c6", "#f0b98d", "#ef9782", "#0fcfc0", "#9cded6", "#d5eae7", "#f3e1eb", "#f6c4e1", "#f79cd4"
      -- "#F94892", "#FF7F3F", "#FBDF07", "#89CFFD"
    }

  }
}
