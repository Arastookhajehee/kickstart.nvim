-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })
vim.keymap.set('n', '<C-S-e>', function()
  local found = false
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == 'neo-tree' then
      found = true
      break
    end
  end
  if found then
    vim.cmd 'Neotree close'
  else
    vim.cmd 'Neotree reveal'
  end
end, { desc = 'NeoTree toggle', silent = true })

require('neo-tree').setup {
  filesystem = {
    hijack_netrw_behavior = 'disabled',
    follow_current_file = {
      enabled = true,
      leave_dirs_open = false,
    },
    filtered_items = {
      visible = true,
      show_hidden_count = true,
      hide_dotfiles = true,
      hide_gitignore = true,
    },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}
