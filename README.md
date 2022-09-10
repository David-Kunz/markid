# markid

A Neovim extension to highlight reoccurring identifiers with the same name.


## Installation

Requirements: [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) including a parser for your language

For [vim-plug](https://github.com/junegunn/vim-plug):
```
Plug 'David-Kunz/markid'
```
For [packer](https://github.com/wbthomason/packer.nvim):
```
use 'David-Kunz/markid'
```

Enable the [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) plugin:

```lua
require'nvim-treesitter.configs'.setup {
  markid = { enable = true }
}
```

## Options

These are the configuration options (with defaults):

```lua
require'nvim-treesitter.configs'.setup {
  markid = {
    enable = true ,
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
```
