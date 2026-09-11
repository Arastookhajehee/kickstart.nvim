local os_type = vim.env.NVIM_OS_TYPE

vim.pack.add {
  'https://github.com/EdenEast/nightfox.nvim',
  'https://github.com/Mofiqul/dracula.nvim',
}

-- require("nightfox").setup({
--   options = {
--     -- transparent = true, -- remove this if you do not want transparency
--     terminal_colors = true,
--     styles = {
--       comments = "italic",
--       keywords = "bold",
--       types = "italic,bold",
--     },
--   },
-- })

------   # THEME # -------
require('dracula').setup {
  transparent_bg = true,
  italic_comment = true,
}

vim.cmd.colorscheme 'dracula'

local function clear_background()
  for _, group in ipairs { 'Normal', 'NormalNC', 'NormalFloat', 'FloatBorder', 'SignColumn', 'EndOfBuffer' } do
    vim.api.nvim_set_hl(0, group, { bg = 'NONE' })
  end
end

clear_background()
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = clear_background,
})

------   # TERMINAL # -------
if os_type == 'WIN' then vim.opt.shell = 'pwsh.exe' end

------   # CODE APPEARANCE # -------
vim.opt.wrap = false

------   # spell check # -------
vim.opt.spelllang = 'en_us'
vim.opt.spell = true
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function(args)
    vim.wo.spell = false
    -- Disable LSP diagnostics for this terminal buffer
    vim.diagnostic.enable(false, { bufnr = args.buf })
  end,
})
