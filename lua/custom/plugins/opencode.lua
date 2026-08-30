vim.pack.add {
  'https://github.com/folke/snacks.nvim',
  {
    src = 'https://github.com/nickjvandyke/opencode.nvim',
    version = vim.version.range '*', -- Latest stable release
  },
}

require('snacks').setup {
  terminal = {},
}

local is_windows = vim.fn.has 'win32' == 1
---@type snacks.terminal.Opts
local snacks_terminal_opts = {
  win = {
    position = 'bottom',
    enter = false,
  },
}

local opencode_port = vim.env.OPENCODE_PORT or '40801'
local opencode_url = vim.env.OPENCODE_URL or ('http://localhost:' .. opencode_port)
local opencode_cmd = { 'opencode', '--port', opencode_port }
local opencode_attach_cmd = { 'opencode', 'attach', opencode_url }

if is_windows then
  opencode_cmd = { 'cmd.exe', '/c', 'opencode', '--port', opencode_port }
  opencode_attach_cmd = { 'cmd.exe', '/c', 'opencode', 'attach', opencode_url }
end

local function show_opencode_terminal()
  local term = require('snacks.terminal').get(opencode_cmd, snacks_terminal_opts)
  term:show()
end

local server_opts = {
  url = opencode_url,
  start = show_opencode_terminal,
}

---@type opencode.Opts
vim.g.opencode_opts = {
  server = server_opts,
  select = {
    prompts = {
      tutor = '/tutor Use the tutor skill. The user has edited or commented on the active tutorial markdown file and wants it reviewed. Find the tutorial/instruction sheet for this project, read its latest contents, and append the next tutor update to the end of that same file. Preserve prior content and follow the tutor skill rules.',
      mycommit = 'Write a concise commit message for @diff',
    },
  },
}

-- Recommended/example keymaps
vim.keymap.set({ 'n', 'x' }, '<leader>a', function() require('opencode').ask '@this: ' end, { desc = 'Ask OpenCode…' })
vim.keymap.set({ 'n', 'x' }, '<leader>x', function() require('opencode').select() end, { desc = 'Select OpenCode…' })
vim.keymap.set({ 'n', 'x' }, 'go', function() return require('opencode').operator '@this ' end, { desc = 'Append range to OpenCode', expr = true })
vim.keymap.set({ 'n' }, 'goo', function() return require('opencode').operator '@this ' .. '_' end, { desc = 'Append line to OpenCode', expr = true })
vim.keymap.set({ 'n' }, '<S-C-k>', function() require('opencode').command 'session.half.page.up' end, { desc = 'Scroll OpenCode up' })
vim.keymap.set({ 'n' }, '<S-C-j>', function() require('opencode').command 'session.half.page.down' end, { desc = 'Scroll OpenCode down' })
vim.keymap.set('n', '<leader>.', function() require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts) end, { desc = 'Toggle OpenCode terminal' })
vim.keymap.set('n', '<leader>A', function() require('snacks.terminal').toggle(opencode_attach_cmd, snacks_terminal_opts) end, { desc = 'Attach OpenCode' })
