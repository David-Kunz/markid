# markid

A Neovim extension to highlight identical identifiers with the same color.

## Motivation

Syntax highlighting is mostly based on element kinds of the abstract syntax tree.
This sometimes leads to different visual representations of the same variable, consider this example:

![usual](https://user-images.githubusercontent.com/1009936/189521671-c654d2ad-17c0-4559-a58d-a10b0e4f2011.png)

Notice the two different representations for `myParam`. 

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
local m = require'markid'
require'nvim-treesitter.configs'.setup {
  markid = {
    enable = true,
    colors = m.colors.medium,
    queries = m.queries,
    is_supported = function(lang)
      local queries = configs.get_module("markid").queries
      return pcall(vim.treesitter.parse_query, lang, queries[lang] or queries['default'])
    end
  }
}

m.colors = {
  dark = { '#619e9d', '#9E6162', '#81A35C', '#7E5CA3', '#9E9261', '#616D9E', '#97687B', '#689784', '#999C63', '#66639C', '#967869', '#698796', '#9E6189', '#619E76' },
  bright = { '#f5c0c0', '#f5d3c0', '#f5eac0', '#dff5c0', '#c0f5c8', '#c0f5f1', '#c0dbf5', '#ccc0f5', '#f2c0f5' },
  medium = {'#c99d9d', '#c9a99d', '#c9b79d', '#c9c39d', '#bdc99d', '#a9c99d', '#9dc9b6', '#9dc2c9', '#9da9c9', '#b29dc9', '#c99dc1' }
}

m.queries = {
  default = '(identifier) @markid',
  javascript = [[
          (identifier) @markid
          (property_identifier) @markid
          (shorthand_property_identifier_pattern) @markid
        ]]
}
m.queries.typescript = m.queries.javascript
```
