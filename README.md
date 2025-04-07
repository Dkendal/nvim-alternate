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
  pairs = {
    -- Simple pairs (source and test)
    {'lua/*.lua', 'tests/*_spec.lua'},
    
    -- Example for specific file types
    {'src/components/*.tsx', 'src/components/*.test.tsx'},
    {'src/lib/*.ts', 'tests/lib/*.test.ts'},
    
    -- Custom pairing with advanced matching
    {{'*/models/*.rb'}, '(.+)/models/(.+).rb', '%1/spec/models/%2_spec.rb'},
  }
})
```

## Usage

Map a key to access the alternate file:

```lua
-- Use the provided <Plug> mapping
vim.keymap.set('n', '<leader>a', '<Plug>(alternate-edit)', { noremap = false })

-- Or map directly to the function
vim.keymap.set('n', '<leader>a', require('nvim-alternate').plug.edit)
```

### Commands

- `:AlternatePrint` - Print the current alternate file path

## Examples

### Ruby on Rails

```lua
require('nvim-alternate').setup({
  pairs = {
    -- Models and specs
    {'app/models/*.rb', 'spec/models/*_spec.rb'},
    -- Controllers and specs
    {'app/controllers/*.rb', 'spec/controllers/*_spec.rb'},
    -- Views and specs
    {'app/views/*/*.erb', 'spec/views/*/*_spec.rb'},
  }
})
```

### JavaScript/TypeScript

```lua
require('nvim-alternate').setup({
  pairs = {
    {
      { "*.ts", "*.tsx", "*.js", "*.jsx" },
      "(.+).([jt]sx?)",
      "%1.test.%2",
    },
    {
      { "*.test.ts", "*.test.tsx", "*.js", "*.jsx" },
      "(.+).test.([jt]sx?)",
      "%1.%2",
    },
  }
})
```

### Elixir

```lua
require('nvim-alternate').setup({
  pairs = {
    { "lib/*.ex",        "test/*_test.exs" },
    { "lib/*/live/*.ex", "lib/*/live/*.html.heex" },
    { "apps/*/lib/*.ex", "apps/*/test/*_test.exs" },
  }
})
```

## License

MIT
