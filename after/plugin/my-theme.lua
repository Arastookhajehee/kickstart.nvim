vim.pack.add({
  "https://github.com/EdenEast/nightfox.nvim",
})

require("nightfox").setup({
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

vim.cmd.colorscheme("nordfox")
