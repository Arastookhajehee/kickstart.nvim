vim.pack.add { 'https://github.com/monaqa/dial.nvim' }

local map = require 'dial.map'

vim.keymap.set('n', '+', map.inc_normal())
vim.keymap.set('n', '-', map.dec_normal())
vim.keymap.set('n', 'g<C-a>', map.inc_gnormal())
vim.keymap.set('n', 'g<C-x>', map.dec_gnormal())
vim.keymap.set('x', '+', map.inc_visual())
vim.keymap.set('x', '-', map.dec_visual())
vim.keymap.set('x', 'g<C-a>', map.inc_gvisual())
vim.keymap.set('x', 'g<C-x>', map.dec_gvisual())
