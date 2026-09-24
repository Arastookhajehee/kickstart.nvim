local map = vim.keymap.set

local function insert_date_jst()
  local stamp = vim.fn.system { 'date', '-u', '-d', '+9 hours', '+%Y%m%d-%H:%M' }
  if vim.v.shell_error ~= 0 then stamp = os.date('!%Y%m%d-%H:%M', os.time() + 9 * 60 * 60) end
  vim.api.nvim_put({ vim.trim(stamp) }, 'c', true, true)
end

local function set_mark(is_global)
  local mark = vim.fn.input(is_global and 'Global mark (A-Z): ' or 'Local mark (a-z): ')
  if mark == '' then return end
  mark = is_global and mark:sub(1, 1):upper() or mark:sub(1, 1):lower()
  if not mark:match(is_global and '[A-Z]' or '[a-z]') then
    vim.notify('Invalid mark', vim.log.levels.WARN)
    return
  end
  vim.cmd('mark ' .. mark)
  vim.notify('Set mark ' .. mark)
end

map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

map('n', 'U', '<C-r>')
map('n', 'j', 'gj')
map('n', 'k', 'gk')
map({ 'n', 'x' }, 'y', '"+y', { noremap = true, silent = true })
map('n', 'Y', '"+yy', { noremap = true, silent = true })
map({ 'n', 'x' }, 'd', '"_d', { noremap = true, silent = true })
map({ 'n', 'x' }, 'c', '"_c', { noremap = true, silent = true })
map({ 'n', 'x' }, 'x', '"_x', { noremap = true, silent = true })
map({ 'n', 'x' }, 'D', '"_D', { noremap = true, silent = true })
map({ 'n', 'x' }, 'C', '"_C', { noremap = true, silent = true })
map({ 'n', 'x' }, 's', '"_s', { noremap = true, silent = true })
map({ 'n', 'x' }, 'S', '"_S', { noremap = true, silent = true })
map('n', 'X', '"+x', { noremap = true, silent = true })
map('x', 'X', '"+d', { noremap = true, silent = true })
map('x', 'p', '"_dP', { noremap = true, silent = true })
map('x', 'P', '"_dP', { noremap = true, silent = true })

map('x', 'J', ":m '>+1<CR>gv=gv")
map('x', 'K', ":m '<-2<CR>gv=gv")
map('n', 'J', 'mzJ`z')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map({ 'n', 'x' }, '{', '{zz')
map({ 'n', 'x' }, '}', '}zz')
map({ 'n', 'x' }, '"', '}zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map({ 'n', 'x', 'o' }, 'H', '0', { noremap = true, silent = true })
map({ 'n', 'x', 'o' }, 'L', '$', { noremap = true, silent = true })

map('x', '<C-_>', 'gc', { remap = true, desc = 'Toggle comment selection' })
map('x', '<C-/>', 'gc', { remap = true, desc = 'Toggle comment selection' })
map('x', '<C-S-/>', 'gc', { remap = true, desc = 'Toggle comment selection' })
map('i', 'ii', '<Esc>')
map('t', 'ii', '<Esc><Esc>')

map('n', '<leader>zig', '<cmd>LspRestart<CR>')
map('n', '<leader>r', [[:%s/\<<C-r><C-w>\>//gc<Left><Left><Left>]], { desc = 'Replace current word' })
map('x', '<leader>r', [[:s/\%V//gc<Left><Left><Left><Left>]], { desc = 'Replace in selection' })
map('n', '<leader>do', vim.diagnostic.open_float, { desc = 'Open diagnostics float' })
map('n', '<leader>h', vim.lsp.buf.hover, { desc = 'Hover docs' })
map({ 'n', 'x' }, '<leader>H', vim.lsp.buf.code_action, { desc = 'Code action' })
map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Save file' })
map('n', '<leader>c', '<cmd>Gitsigns next_hunk<CR>', { desc = 'Next git hunk' })
map('n', '<leader>C', '<cmd>Gitsigns prev_hunk<CR>', { desc = 'Previous git hunk' })
map({ 'n', 'i' }, '<leader>id', insert_date_jst, { desc = 'Insert JST date string' })
map('n', '<leader>m', function() set_mark(false) end, { desc = 'Set local mark' })
map('n', '<leader>M', function() set_mark(true) end, { desc = 'Set global mark' })
map('n', '<leader>T', '<cmd>terminal<CR>', { desc = 'Open terminal' })

require 'custom.plugins.mark_align'
require 'custom.plugins.visual-studio-navigation'
