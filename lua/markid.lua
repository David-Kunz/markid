local ts = require('nvim-treesitter')
local parsers = require("nvim-treesitter.parsers")
local configs = require("nvim-treesitter.configs")

local namespace = vim.api.nvim_create_namespace("markid")

local get_root = function(parser)
  local tree = parser:parse()[1]
  return tree:root()
end

local get_query = function(lang, config)
  return vim.treesitter.parse_query(lang, config.queries[lang] or config.default_query)
end

function string_to_int(str)
  if str == nil then return 0 end
  local int = 0
  for i = 1, #str do
    local c = str:sub(i, i)
    int = int + string.byte(c)
  end
  return int
end

local M = {}

function M.init()
  ts.define_modules {
    markid = {
      module_path = "markid",

      attach = function(bufnr, lang)
        local config = configs.get_module("markid")

        local query = get_query(lang, config)
        local parser = parsers.get_parser(bufnr, lang)
        local root = get_root(parser)

        local hl_group_of_identifier = {}

        function highlight_tree(tree, cap_start, cap_end)
          vim.api.nvim_buf_clear_namespace(bufnr, namespace, cap_start, cap_end)
          for id, node in query:iter_captures(tree, bufnr, cap_start, cap_end) do
            local name = query.captures[id]
            if name == "markid" then
              local text = vim.treesitter.query.get_node_text(node, bufnr)
              if hl_group_of_identifier[text] == nil then
                -- semi random: Allows to have stable global colors for the same name
                local idx = (string_to_int(text) % #config.colors) + 1
                local group_name = "markid" .. idx
                vim.highlight.create(group_name, { guifg = config.colors[idx] })
                hl_group_of_identifier[text] = group_name
              end
              local start_row, start_col, end_row, end_col = node:range()
              local range_start = { start_row, start_col }
              local range_end = { end_row, end_col }
              vim.highlight.range(bufnr, namespace, hl_group_of_identifier[text], range_start, range_end)
            end
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
        local config = configs.get_module("markid")
        return pcall(vim.treesitter.parse_query, lang, config.queries[lang] or config.default_query)
      end,

      colors = {
        "#bf6060", "#bf9f60", "#bcbf60", "#60bf91", "#60b7bf", "#607cbf", "#7860bf", "#a160bf", "#bf6093"
      },

      queries = {
        javascript = [[
          (identifier) @markid
          (property_identifier) @markid
        ]],
        typescript = [[
          (identifier) @markid
          (property_identifier) @markid
        ]]
      },
      default_query = '(identifier) @markid'
    }
  }
end

return M
