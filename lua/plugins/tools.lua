return {
  {
    'folke/snacks.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      rename = { enabled = true },
      scratch = { enabled = true },
      terminal = { enabled = true },
    },
    keys = {
      { '<leader>ns', function() Snacks.scratch() end, desc = 'Scratch buffer' },
      { '<leader>nS', function() Snacks.scratch.select() end, desc = 'Select scratch buffer' },
    },
  },
  {
    'nickjvandyke/opencode.nvim',
    version = '*',
    dependencies = { 'folke/snacks.nvim' },
    keys = {
      { '<leader>a', mode = { 'n', 'x' } },
      { '<leader>x', mode = { 'n', 'x' } },
      { 'go', mode = { 'n', 'x' } },
      { 'goo' },
      { '<S-C-k>' },
      { '<S-C-j>' },
      { '<leader>.' },
      { '<leader>A' },
    },
    config = function() require 'custom.plugins.opencode' end,
  },
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = { dir = vim.fn.stdpath 'state' .. '/sessions' },
    keys = {
      { '<leader>ps', function() require('persistence').load() end, desc = 'Restore session' },
      { '<leader>pl', function() require('persistence').load { last = true } end, desc = 'Restore last session' },
      { '<leader>pd', function() require('persistence').stop() end, desc = 'Do not save session' },
    },
  },
  {
    'MagicDuck/grug-far.nvim',
    cmd = 'GrugFar',
    keys = {
      {
        '<leader>rg',
        function() require('grug-far').open { prefills = { search = vim.fn.expand '<cword>' } } end,
        mode = { 'n', 'x' },
        desc = 'Project search and replace',
      },
    },
    opts = {},
  },
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    keys = {
      { '<leader>zd', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Workspace diagnostics' },
      { '<leader>zD', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer diagnostics' },
      { '<leader>zs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Document symbols' },
      { '<leader>zl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP definitions/references' },
      { '<leader>zq', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix list' },
    },
    opts = {},
  },
  {
    'folke/flash.nvim',
    opts = {
      highlight = {
        backdrop = false,
      },
      mode = {
        char = {
          highlight = {
            backdrop = false,
          },
        },
      },
    },
    keys = {
      { 'gs', function() require('flash').jump() end, mode = { 'n', 'x', 'o' }, desc = 'Flash jump' },
      { 'gS', function() require('flash').treesitter() end, mode = { 'n', 'x', 'o' }, desc = 'Flash Treesitter' },
    },
  },
}
