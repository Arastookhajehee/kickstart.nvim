vim.pack.add {
  { src = 'https://github.com/cajames/copy-reference.nvim' },
  { src = 'https://github.com/h3pei/copy-file-path.nvim' },
}

require('copy-reference').setup {
  register = '+',
  use_git_root = true,
}

local set = vim.keymap.set

set({ 'n', 'x' }, '<leader>yr', '<cmd>CopyReference file<cr>', { desc = 'Copy relative file path' })
set({ 'n', 'x' }, '<leader>yL', '<cmd>CopyReference line<cr>', { desc = 'Copy file path and line' })
set('n', '<leader>ya', '<cmd>CopyAbsoluteFilePath<cr>', { desc = 'Copy absolute file path' })
set('x', '<leader>ya', ":'<,'>CopyAbsoluteFilePath<cr>", { desc = 'Copy absolute file path and range' })
set({ 'n', 'v' }, '<leader>yA', function() vim.cmd(('%dCopyAbsoluteFilePath'):format(vim.fn.line '.')) end, { desc = 'Copy absolute file path and line' })
set('n', '<leader>yh', '<cmd>CopyRelativeFilePathFromHome<cr>', { desc = 'Copy file path from home' })
set('x', '<leader>yH', ":'<,'>CopyRelativeFilePathFromHome<cr>", { desc = 'Copy file path from home and range' })
set('n', '<leader>yn', '<cmd>CopyFileName<cr>', { desc = 'Copy file name' })
