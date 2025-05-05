# nvim-alternate

A Neovim plugin that provides alternate file mappings, similar to [vim-projectionist](https://github.com/tpope/vim-projectionist), allowing you to quickly jump between related files (like source and test files).

## Features

- Define pairs of file patterns to switch between
- Jump to alternate files with a single command
- Customizable pattern matching with glob support
- Automatic detection of alternate files on buffer enter

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'dkendal/nvim-alternate',
  lazy = false, -- Important
  config = function()
    require('nvim-alternate').setup({
      -- Configuration (see below)
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'dkendal/nvim-alternate',
  config = function()
    require('nvim-alternate').setup({
      -- Configuration (see below)
    })
  end
}
```

## Configuration

```lua
require('nvim-alternate').setup({
  rules = {
    -- Glob patterns (matching pairs of files)
    { glob = { "lua/*.lua", "tests/*_spec.lua" } },
    
    -- Regular patterns with Lua pattern matching
    { pattern = { "(.+).([jt]sx?)$", "%1.test.%2" } },
    { pattern = { "(.+).test.([jt]sx?)$", "%1.%2" } },
  }
})
```

## Usage

Map a key to access the alternate file:

```lua
-- Use the provided <Plug> mapping
vim.keymap.set('n', '<leader>a', '<plug>(alternate-edit)', { noremap = false })

-- Or map directly to the function
vim.keymap.set('n', '<leader>a', require('nvim-alternate').plug.edit)
```

### Commands

- `:AlternatePrint` - Print the current alternate file path

## Example Configuration

This example shows how to configure the plugin with lazy.nvim:

```lua
{
    dir = "dkendal/nvim-alternate",
    lazy = false,
    opts = {
        rules = {
            -- Haskell
            { glob = { "src/*.hs", "test/*Spec.hs" } },
            -- Elixir
            { glob = { "lib/*.ex", "test/*_test.exs" } },
            { glob = { "lib/*/live/*.ex", "lib/*/live/*.html.heex" } },
            { glob = { "apps/*/lib/*.ex", "apps/*/test/*_test.exs" } },
            -- Ruby
            { glob = { "app/*.rb", "test/*_test.rb" } },
            { glob = { "test/*_test.rb", "app/*.rb" } },
            -- Lua
            { glob = { "lua/*.lua", "tests/*_spec.lua" } },
            -- Typescript / Javascript
            { pattern = { "(.+).([jt]sx?)$", "%1.test.%2" } },
            { pattern = { "(.+).test.([jt]sx?)$", "%1.%2" } },
        },
    },
    keys = {
        { "<leader>pa", "<plug>(alternate-edit)" },
    },
},
```

## Examples by Language

### Ruby on Rails

```lua
require('nvim-alternate').setup({
  rules = {
    -- Models and specs
    { glob = { "app/models/*.rb", "spec/models/*_spec.rb" } },
    -- Controllers and specs
    { glob = { "app/controllers/*.rb", "spec/controllers/*_spec.rb" } },
    -- Views and specs
    { glob = { "app/views/*/*.erb", "spec/views/*/*_spec.rb" } },
  }
})
```

### JavaScript/TypeScript

```lua
require('nvim-alternate').setup({
  rules = [
    { pattern = { "(.+).([jt]sx?)$", "%1.test.%2" } },
    { pattern = { "(.+).test.([jt]sx?)$", "%1.%2" } },
  ]
})
```

### Elixir

```lua
require('nvim-alternate').setup({
  rules = {
    { glob = { "lib/*.ex", "test/*_test.exs" } },
    { glob = { "lib/*/live/*.ex", "lib/*/live/*.html.heex" } },
    { glob = { "apps/*/lib/*.ex", "apps/*/test/*_test.exs" } },
  }
})
```

## License

MIT
