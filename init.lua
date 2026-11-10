vim.loader.enable()

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false
vim.g.nvim_profile = vim.env.NVIM_PROFILE or 'full'
if vim.g.nvim_profile ~= 'full' and vim.g.nvim_profile ~= 'opencode-editor' then
  error('Unknown NVIM_PROFILE: ' .. vim.g.nvim_profile)
end

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.lazy'
