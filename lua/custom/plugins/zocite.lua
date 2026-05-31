vim.pack.add({
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/jalvesaq/zotcite",
})

require("nvim-treesitter").setup({})

local user = os.getenv("WIN_USERNAME")
path = "/mnt/c/Users/" .. user .. "/Zotero/zotero.sqlite"

require("zotcite").setup({
  zotero_sqlite_path = path,
  -- key_type = "template", -- "template" | "better-bibtex" | "zotero"
})

vim.keymap.set("i", "<C-b>", "<Plug>ZCite")

vim.keymap.set("n", "<leader>zc", function()
  vim.api.nvim_feedkeys("a", "n", false)
  vim.schedule(function()
    vim.api.nvim_feedkeys(vim.keycode("<C-b>"), "m", false)
  end)
end, { silent = true, desc = "Insert Zotero citation" })
