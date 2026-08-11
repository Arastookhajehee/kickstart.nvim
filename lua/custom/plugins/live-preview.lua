vim.pack.add {
  'https://github.com/brianhuster/live-preview.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
}

require('livepreview.config').set {
  port = 5500,
  browser = 'default',
}
