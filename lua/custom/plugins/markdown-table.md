vim.pack.add {
  {
    src = 'https://github.com/Kicamon/markdown-table-mode.nvim',
    name = 'markdown-table-mode.nvim',
  },
}

require('markdown-table-mode').setup {
  filetype = {
    '*.md',
    '*.markdown',
  },
  options = {
    insert = true,
    insert_leave = true,
    pad_separator_line = false,
    alig_style = 'default', -- yes, the plugin option is spelled 'alig_style'
  },
}
