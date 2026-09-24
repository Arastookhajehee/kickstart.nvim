return {
  {
    'Mofiqul/dracula.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('dracula').setup {
        options = {
          terminal_colors = true,
          styles = { comments = 'italic', keywords = 'bold', types = 'italic,bold' },
        },
      }
      vim.cmd.colorscheme 'dracula'
    end,
  },
  {
    'nvim-mini/mini.nvim',
    lazy = false,
    config = function()
      if vim.g.have_nerd_font then
        require('mini.icons').setup()
        MiniIcons.mock_nvim_web_devicons()
      end
      require('mini.ai').setup {
        mappings = { around_next = 'aa', inside_next = 'ii' },
        n_lines = 500,
      }
      require('mini.comment').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function() return '%2l:%-2v' end
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { 'gr', group = 'LSP Actions', mode = 'n' },
      },
    },
  },
  { 'NMAC427/guess-indent.nvim', event = { 'BufReadPost', 'BufNewFile' }, opts = {} },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require 'kickstart.plugins.gitsigns' end,
  },
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {},
  },
}
