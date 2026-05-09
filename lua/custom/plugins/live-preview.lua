local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'brianhuster/live-preview.nvim',
  gh 'nvim-telescope/telescope.nvim',
}

require('livepreview.config').set {
  port = 5500,
  browser = 'default',
}
