local map = vim.keymap.set

local function with_telescope(callback)
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and builtin then
    callback(builtin)
    return true
  end
  return false
end

local function vscode_like_find_in_buffer() vim.api.nvim_feedkeys('/', 'n', false) end

local function set_mark(is_global)
  local label = is_global and 'Global mark (A-Z): ' or 'Local mark (a-z): '
  local mark = vim.fn.input(label)
  if mark == '' then return end
  mark = mark:sub(1, 1)
  mark = is_global and mark:upper() or mark:lower()
  if not mark:match(is_global and '[A-Z]' or '[a-z]') then
    vim.notify('Invalid mark', vim.log.levels.WARN)
    return
  end
  vim.cmd('mark ' .. mark)
  vim.notify('Set mark ' .. mark)
end

map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', 'U', '<C-r>')
map('n', 'j', 'gj')
map('n', 'k', 'gk')

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.isfname:append '@-@'
vim.opt.colorcolumn = '100,120'
vim.opt.clipboard = 'unnamedplus'

map({ 'n', 'v' }, 'y', '"+y', { noremap = true, silent = true })
map('n', 'Y', '"+yy', { noremap = true, silent = true })
map({ 'n', 'v' }, 'd', '"_d', { noremap = true, silent = true })
map({ 'n', 'v' }, 'c', '"_c', { noremap = true, silent = true })
map({ 'n', 'v' }, 'x', '"_x', { noremap = true, silent = true })
map({ 'n', 'v' }, 'D', '"_D', { noremap = true, silent = true })
map({ 'n', 'v' }, 'C', '"_C', { noremap = true, silent = true })
map({ 'n', 'v' }, 's', '"_s', { noremap = true, silent = true })
map({ 'n', 'v' }, 'S', '"_S', { noremap = true, silent = true })
map('n', 'X', '"+x', { noremap = true, silent = true })
map('v', 'X', '"+d', { noremap = true, silent = true })
map('v', 'p', '"_dP', { noremap = true, silent = true })
map('v', 'P', '"_dP', { noremap = true, silent = true })

map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")
map('n', 'J', 'mzJ`z')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', '<leader>zig', '<cmd>LspRestart<CR>')

map('i', '<Tab>', function() return vim.fn.pumvisible() == 1 and '<C-y>' or '<Tab>' end, { expr = true })
map('i', 'jj', '<Esc>')

map('n', '<leader>f', vscode_like_find_in_buffer, { desc = 'Find in buffer' })
map('n', '<leader>r', [[:%s/\<<C-r><C-w>\>//gc<Left><Left><Left>]], { desc = 'Replace current word' })
map('x', '<leader>r', [[:s/\%V//gc<Left><Left><Left><Left>]], { desc = 'Replace in selection' })

map('n', '<leader>d', function()
  if vim.bo.filetype == 'markdown' then
    local target = vim.fn.expand '<cfile>'
    if target ~= '' and vim.ui and vim.ui.open then
      vim.ui.open(target)
      return
    end
  end
  vim.lsp.buf.definition()
end, { desc = 'Go to definition' })

map('n', '<leader>D', function() vim.lsp.buf.references() end, { desc = 'Go to references' })

map('n', '<leader>h', function() vim.lsp.buf.hover() end, { desc = 'Hover docs' })

map({ 'n', 'x' }, '<leader>H', function() vim.lsp.buf.code_action() end, { desc = 'Code action' })

map('n', '<leader>g', function()
  if with_telescope(function(builtin) builtin.live_grep() end) then return end
  vscode_like_find_in_buffer()
end, { desc = 'Search text' })

map('n', '<leader>z', function()
  if with_telescope(function(builtin) builtin.live_grep() end) then return end
  vscode_like_find_in_buffer()
end, { desc = 'Global fuzzy search' })

map('n', '<leader>o', function()
  if with_telescope(function(builtin) builtin.find_files() end) then return end
  vim.cmd 'edit .'
end, { desc = 'Find files' })

map('n', '<leader>p', function()
  if with_telescope(function(builtin) builtin.find_files() end) then return end
  vim.cmd 'edit .'
end, { desc = 'Quick open' })

map('n', '<leader>s', function()
  if with_telescope(function(builtin) builtin.lsp_document_symbols() end) then return end
  vim.lsp.buf.document_symbol()
end, { desc = 'Document symbols' })

map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Save file' })

map('n', '<leader>m', function() set_mark(false) end, { desc = 'Set local mark' })

map('n', '<leader>M', function() set_mark(true) end, { desc = 'Set global mark' })

map('n', "<leader>'", '<cmd>marks<CR>', { desc = 'List marks' })
map('n', '<leader>"', '<cmd>marks<CR>', { desc = 'List all marks' })
