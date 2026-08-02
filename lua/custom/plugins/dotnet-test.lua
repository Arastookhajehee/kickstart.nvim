vim.pack.add {
  'https://github.com/nvim-neotest/neotest',
  'https://github.com/citizenharris/neotest-dotnet',
  'https://github.com/antoinemadec/FixCursorHold.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-neotest/nvim-nio',
}

local ok, neotest = pcall(require, 'neotest')
if not ok then return end

neotest.setup {
  adapters = {
    require 'neotest-dotnet',
  },
}

vim.keymap.set('n', '<leader>tt', function() neotest.run.run() end, { desc = 'Test: Run nearest' })
vim.keymap.set('n', '<leader>tf', function() neotest.run.run(vim.fn.expand '%') end, { desc = 'Test: Run file' })
vim.keymap.set('n', '<leader>ts', function() neotest.summary.toggle() end, { desc = 'Test: Toggle summary' })
vim.keymap.set('n', '<leader>to', function() neotest.output.open { enter = true } end, { desc = 'Test: Show output' })
vim.keymap.set('n', '<leader>dt', function() neotest.run.run { strategy = 'dap' } end, { desc = 'Debug: Nearest test' })
vim.keymap.set('n', '<F6>', function() neotest.run.run { strategy = 'dap' } end, { desc = 'Debug: Nearest test' })
