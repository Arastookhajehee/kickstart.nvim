return {
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = vim.fn.has 'win32' == 0 and vim.fn.executable 'make' == 1 and 'make install_jsregexp' or nil,
    dependencies = { 'rafamadriz/friendly-snippets' },
    config = function()
      local ls = require 'luasnip'
      ls.setup {}
      require('luasnip.loaders.from_vscode').lazy_load()
      require 'config.snippets'
    end,
  },
  {
    'saghen/blink.cmp',
    version = '1.*',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = { 'L3MON4D3/LuaSnip', 'folke/lazydev.nvim' },
    opts = {
      keymap = { preset = 'super-tab' },
      appearance = { nerd_font_variant = 'mono' },
      completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },
  {
    'benfowler/telescope-luasnip.nvim',
    keys = {
      {
        '<leader>ls',
        function() require('telescope').extensions.luasnip.luasnip {} end,
        desc = '[L]uaSnip [S]nippets',
      },
    },
    dependencies = { 'nvim-telescope/telescope.nvim', 'L3MON4D3/LuaSnip' },
    config = function() require('telescope').load_extension 'luasnip' end,
  },
}
