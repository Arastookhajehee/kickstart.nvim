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

local function with_telescope_builtin(name, fallback)
  return function(...)
    local ok, builtin = pcall(require, 'telescope.builtin')
    if ok and builtin[name] then
      return builtin[name](...)
    end
    if fallback then return fallback(...) end
  end
end

local function insert_date_jst()
  local stamp = vim.fn.system { 'date', '-u', '-d', '+9 hours', '+%Y%m%d-%H:%M' }
  if vim.v.shell_error ~= 0 then stamp = os.date('!%Y%m%d-%H:%M', os.time() + 9 * 60 * 60) end
  vim.api.nvim_put({ vim.trim(stamp) }, 'c', true, true)
end

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
vim.opt.spell = true
vim.opt.spelllang = 'en_us'

vim.filetype.add {
  pattern = {
    ['.*%.uxml'] = 'xml',
    ['.*%.uss'] = 'css',
    ['%.env.*'] = 'sh',
  },
  filename = {
    ['.env'] = 'sh',
  },
}

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
map('n', '{', '{zz')
map('n', '"', '}zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', '<leader>zig', '<cmd>LspRestart<CR>')

-- line home and end
map({ 'n', 'x', 'o' }, 'H', '0', { noremap = true, silent = true })
map({ 'n', 'x', 'o' }, 'L', '$', { noremap = true, silent = true })

map('x', '<C-_>', 'gc', { remap = true, desc = 'Toggle comment selection' })
map('x', '<C-/>', 'gc', { remap = true, desc = 'Toggle comment selection' })
map('x', '<C-S-/>', 'gc', { remap = true, desc = 'Toggle comment selection' })

map('i', '<Tab>', function()
  local ok, ls = pcall(require, 'luasnip')
  if ok and ls.locally_jumpable(1) then
    ls.jump(1)
    return ''
  end

  return vim.fn.pumvisible() == 1 and '<C-y>' or '<Tab>'
end, { expr = true, silent = true })
map('i', 'ii', '<Esc>')
map('t', 'ii', '<Esc><Esc>')

-- map('n', '<leader>f', vscode_like_find_in_buffer, { desc = 'Find in buffer' })
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
  with_telescope_builtin('lsp_definitions', vim.lsp.buf.definition)()
end, { desc = 'Go to definition' })

map('n', '<leader>D', with_telescope_builtin('lsp_references', vim.lsp.buf.references), { desc = 'Go to references' })

map('n', '<leader>h', function() vim.lsp.buf.hover() end, { desc = 'Hover docs' })

map({ 'n', 'x' }, '<leader>H', function() vim.lsp.buf.code_action() end, { desc = 'Code action' })

map('n', '<leader>q', with_telescope_builtin('quickfix', vim.diagnostic.setloclist), { desc = 'Quickfix picker' })

map('n', '<leader>g', function()
  if with_telescope(function(builtin) builtin.live_grep() end) then return end
  vscode_like_find_in_buffer()
end, { desc = 'Search text' })

map('n', '<leader>s', function()
  if with_telescope(function(builtin) builtin.lsp_document_symbols() end) then return end
  vim.lsp.buf.document_symbol()
end, { desc = 'Document symbols' })
vim.keymap.set('n', '<leader>sq', with_telescope_builtin('quickfix', vim.diagnostic.setloclist), { desc = '[S]earch [Q]uickfix' })

map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Save file' })

map('n', '<leader>c', '<cmd>Gitsigns next_hunk<CR>', { desc = 'Next git hunk' })
map('n', '<leader>C', '<cmd>Gitsigns prev_hunk<CR>', { desc = 'Previous git hunk' })

map({ 'n', 'i' }, '<leader>id', insert_date_jst, { desc = 'Insert JST date string' })

map('n', '<leader>m', function() set_mark(false) end, { desc = 'Set local mark' })

map('n', '<leader>M', function() set_mark(true) end, { desc = 'Set global mark' })

map('n', "<leader>'", with_telescope_builtin('marks', function() vim.cmd 'marks' end), { desc = 'List marks' })
map('n', '<leader>"', with_telescope_builtin('marks', function() vim.cmd 'marks' end), { desc = 'List all marks' })
