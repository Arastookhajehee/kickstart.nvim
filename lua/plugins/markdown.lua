local not_windows = function() return vim.env.NVIM_OS_TYPE ~= 'WIN' and vim.fn.has 'win32' == 0 end

return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'markdown.mdx' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
    config = function() require 'custom.plugins.render-markdown' end,
  },
  {
    'SCJangra/table-nvim',
    ft = 'markdown',
    config = function() require 'custom.plugins.markdown-table' end,
  },
  {
    'brianhuster/live-preview.nvim',
    cmd = 'LivePreview',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function() require 'custom.plugins.live-preview' end,
  },
  {
    '3rd/image.nvim',
    ft = { 'markdown', 'vimwiki', 'typst', 'norg' },
    event = {
      'BufReadPre *.png',
      'BufReadPre *.jpg',
      'BufReadPre *.jpeg',
      'BufReadPre *.gif',
      'BufReadPre *.webp',
      'BufReadPre *.avif',
    },
    cond = not_windows,
    config = function() require 'custom.plugins.image' end,
  },
  {
    '3rd/diagram.nvim',
    ft = { 'markdown', 'norg' },
    cond = not_windows,
    dependencies = { '3rd/image.nvim' },
    config = function() require 'custom.plugins.diagram-nvim' end,
  },
  {
    'jalvesaq/zotcite',
    ft = 'markdown',
    cond = function() return vim.env.NVIM_ZOTERO_DB_PATH ~= nil and vim.env.NVIM_ZOTERO_DB_PATH ~= '' end,
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-treesitter/nvim-treesitter' },
    config = function() require 'custom.plugins.zocite' end,
  },
  {
    'mfussenegger/nvim-lint',
    ft = 'markdown',
    config = function() require 'kickstart.plugins.lint' end,
  },
  {
    'cskeeters/kokoro.nvim',
    cond = not_windows,
    keys = {
      { '<leader>kk', mode = { 'n', 'v' } },
      { '<leader>kK' },
      { '<leader><leader>kkv' },
      { '<leader><leader>kks' },
    },
    config = function() require 'custom.plugins.kokoro' end,
  },
}
