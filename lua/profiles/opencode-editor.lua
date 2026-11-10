-- Reuse the full profile's plugin definitions so keymaps and configuration stay in sync.
local function pick(module, name)
  for _, spec in ipairs(require(module)) do
    if spec[1] == name then return spec end
  end
  error(('Missing plugin %s in %s'):format(name, module))
end

return {
  pick('plugins.tools', 'folke/flash.nvim'),
  pick('plugins.markdown', 'mfussenegger/nvim-lint'),
  pick('plugins.markdown', 'SCJangra/table-nvim'),
}
