local os_type = vim.env.NVIM_OS_TYPE

vim.pack.add({
  "https://github.com/EdenEast/nightfox.nvim",
  "https://github.com/Mofiqul/dracula.nvim",
})

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
require("dracula").setup({
  options = {
    -- transparent = true, -- remove this if you do not want transparency
    terminal_colors = true,
    styles = {
      comments = "italic",
      keywords = "bold",
      types = "italic,bold",
    },
  },
})

vim.cmd.colorscheme("dracula")

------   # TERMINAL # ------- 
if os_type == "WIN" then
  vim.opt.shell = "pwsh.exe"
end

------   # CODE APPEARANCE # ------- 
vim.opt.wrap = false
