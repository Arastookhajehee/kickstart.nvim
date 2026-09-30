return {
  {
    dir = vim.fn.stdpath 'config' .. '/local-plugins/telescope-super-git-status.nvim',
    name = 'telescope-super-git-status.nvim',
    main = 'super_git_status',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    cmd = 'SuperGitStatus',
    keys = {
      { '<leader>sG', '<cmd>SuperGitStatus<cr>', desc = '[S]earch all [G]it changes' },
    },
    opts = {},
  },
}
