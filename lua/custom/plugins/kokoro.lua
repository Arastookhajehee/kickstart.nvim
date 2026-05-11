vim.pack.add({
  "https://github.com/cskeeters/kokoro.nvim",
})
  -- Make user-installed LuaRocks modules available to Neovim.
  do
    local lr_share = vim.fn.expand '~/.luarocks/share/lua/5.1'
    local lr_lib = vim.fn.expand '~/.luarocks/lib/lua/5.1'
    package.path = package.path .. ';' .. lr_share .. '/?.lua;' .. lr_share .. '/?/init.lua'
    package.cpath = package.cpath .. ';' .. lr_lib .. '/?.so'
  end

local ok, err = pcall(require, 'rex_pcre2')
if not ok then
  -- vim.notify(
  --   'kokoro.nvim: failed to load rex_pcre2 (' .. tostring(err) .. '). Install with: luarocks install --local lrexlib-pcre2 --lua-version=5.1',
  --   vim.log.levels.ERROR
  -- )
  return
end
require('kokoro').setup({
  debug = false,
  notify_min_level = vim.log.levels.ERROR,
  path = vim.fn.expand('~/tools/kokoro_nvim'),
  uv = true,
  player = 'mpv',
  load_voices = true,
  voice = 'af_aoede',
  speed = 1.3,
})
-- NOTE: keep explicit visual range to avoid mode/range ambiguity
vim.keymap.set('v', '<leader>kk', ":'<,'>Kokoro<CR>", { noremap = true, silent = true, desc = 'Read selected text with Kokoro' })
vim.keymap.set('n', '<leader>kk', ':Kokoro<CR>', { noremap = true, silent = true, desc = 'Read current line with Kokoro' })
vim.keymap.set('n', '<leader>kK', ':KokoroStop<CR>', { noremap = true, silent = true, desc = 'Stop Kokoro audio' })
vim.keymap.set('n', '<leader><leader>kkv', ':KokoroChooseVoice<CR>', { noremap = true, silent = true, desc = 'Choose Kokoro voice' })
vim.keymap.set('n', '<leader><leader>kks', ':KokoroChooseSpeed<CR>', { noremap = true, silent = true, desc = 'Choose Kokoro speed' })
