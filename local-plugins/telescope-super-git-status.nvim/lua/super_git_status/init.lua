local M = {}

local configured = false

function M.open(opts) require('super_git_status.picker').open(opts or {}) end

function M.setup()
  if configured then return end
  configured = true

  vim.api.nvim_create_user_command('SuperGitStatus', function() M.open() end, {
    desc = 'Search Git changes across a superproject and its submodules',
  })
end

return M
