vim.pack.add {
  'https://github.com/timantipov/md-table-tidy.nvim',
}

require('md-table-tidy').setup {
  padding = 1,
  keymap = {
    table_tidy = '<leader>tt',
    table_tidy_all = '<leader>ta',
  },
}
