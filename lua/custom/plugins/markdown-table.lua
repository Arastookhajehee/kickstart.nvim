vim.pack.add {
  {
    src = 'https://github.com/SCJangra/table-nvim',
    name = 'table-nvim',
  },
}

require('table-nvim').setup {
  padd_column_separators = true,   -- Insert a space around column separators.
  mappings = {
    insert_table = '<leader>tt',
    insert_column_right = '<leader>tc',
    insert_column_left = '<leader>tC',
    insert_row_down = '<leader>tr',
    insert_row_up = '<leader>tR',
    next = '<TAB>',                -- Go to next cell.
    prev = '<S-TAB>',              -- Go to previous cell.
    move_row_up = '<leader>tk',       -- Move the current row up.
    move_row_down = '<leader>tj',     -- Move the current row down.
    move_column_left = '<leader>th',  -- Move the current column to the left.
    move_column_right = '<leader>tl', -- Move the current column to the right.
    insert_table_alt = '<leader>tT',  -- Insert a new table that is not surrounded by pipes.
    delete_column = '<leader>td',       -- Delete the column under cursor.
  },
}

