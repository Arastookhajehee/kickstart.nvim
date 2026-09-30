return require('telescope').register_extension {
  exports = {
    super_git_status = function(opts) require('super_git_status').open(opts) end,
  },
}
