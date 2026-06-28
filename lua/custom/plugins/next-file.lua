
vim.pack.add {
  { src = 'https://github.com/marwndev/nextfile.nvim'},
}

local nf = require 'nextfile'
nf.setup()

local set = vim.keymap.set

set('n', '<leader>n', '<cmd>NextFile<cr>', { desc = 'Next file' })
set('n', '<leader>N', '<cmd>PrevFile<cr>', { desc = 'Previous file' })
-- set('n', '<leader>e', '<cmd>NextFileSameExt<cr>', { desc = 'Next file (same ext)' })
-- set('n', '<leader>E', '<cmd>PrevFileSameExt<cr>', { desc = 'Previous file (same ext)' })
