local function plugin_keys(keys, mode)
  return vim.tbl_map(function(key) return { key, mode = mode or 'n' } end, keys)
end

return {
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },
  { 'kylechui/nvim-surround', version = '4.*', event = 'VeryLazy', opts = {} },
  {
    'monaqa/dial.nvim',
    keys = {
      { '+', mode = { 'n', 'x' } },
      { '-', mode = { 'n', 'x' } },
      { 'g<C-a>', mode = { 'n', 'x' } },
      { 'g<C-x>', mode = { 'n', 'x' } },
    },
    config = function() require 'custom.plugins.dial' end,
  },
  {
    'jake-stewart/multicursor.nvim',
    branch = '1.0',
    keys = {
      { '<up>', mode = { 'n', 'x' } },
      { '<down>', mode = { 'n', 'x' } },
      { '<leader><up>', mode = { 'n', 'x' } },
      { '<leader><down>', mode = { 'n', 'x' } },
      { '<leader>mn', mode = { 'n', 'x' } },
      { '<leader>ms', mode = { 'n', 'x' } },
      { '<leader>mN', mode = { 'n', 'x' } },
      { '<leader>mS', mode = { 'n', 'x' } },
      { '<c-leftmouse>' },
      { '<c-q>', mode = { 'n', 'x' } },
    },
    config = function() require 'custom.plugins.multi-cursor' end,
  },
  {
    'marwndev/nextfile.nvim',
    cmd = { 'NextFile', 'PrevFile', 'NextFileSameExt', 'PrevFileSameExt' },
    keys = plugin_keys { '<leader>N', '<leader>P' },
    config = function() require 'custom.plugins.next-file' end,
  },
  {
    'cajames/copy-reference.nvim',
    dependencies = { 'h3pei/copy-file-path.nvim' },
    keys = {
      { '<leader>yr', mode = { 'n', 'x' } },
      { '<leader>yL', mode = { 'n', 'x' } },
      { '<leader>ya', mode = { 'n', 'x' } },
      { '<leader>yA', mode = { 'n', 'v' } },
      { '<leader>yh' },
      { '<leader>yH', mode = 'x' },
      { '<leader>yn' },
    },
    config = function() require 'custom.plugins.copy-paths' end,
  },
  { 'TrevorS/uuid-nvim', cmd = { 'UuidV4', 'UuidToggleHighlighting' }, opts = {} },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    keys = {
      { '<leader>ja' },
      { '<leader>jl' },
      { '<leader>jn' },
      { '<leader>jp' },
      { '<leader>j1' },
      { '<leader>j2' },
      { '<leader>j3' },
      { '<leader>j4' },
    },
    config = function() require 'custom.plugins.harpoon' end,
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    cmd = 'Neotree',
    keys = {
      { '\\', '<cmd>Neotree reveal<cr>', desc = 'NeoTree reveal' },
      { '<C-S-e>', '<cmd>Neotree reveal<cr>', desc = 'NeoTree reveal' },
      { '<leader>eb', '<cmd>Neotree buffers toggle<cr>', desc = 'NeoTree buffers' },
      { '<leader>eg', '<cmd>Neotree git_status toggle<cr>', desc = 'NeoTree Git status' },
    },
    dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim' },
    config = function()
      local events = require 'neo-tree.events'
      require('neo-tree').setup {
        sources = { 'filesystem', 'buffers', 'git_status' },
        source_selector = { winbar = true, statusline = false },
        event_handlers = {
          {
            event = events.FILE_MOVED,
            handler = function(data) Snacks.rename.on_rename_file(data.source, data.destination) end,
          },
          {
            event = events.FILE_RENAMED,
            handler = function(data) Snacks.rename.on_rename_file(data.source, data.destination) end,
          },
        },
        filesystem = {
          hijack_netrw_behavior = 'disabled',
          use_libuv_file_watcher = true,
          follow_current_file = { enabled = true, leave_dirs_open = false },
          filtered_items = { visible = true, show_hidden_count = true, hide_dotfiles = true, hide_gitignore = true },
          window = { mappings = { ['\\'] = 'close_window' } },
        },
      }
    end,
  },
}
