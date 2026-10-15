local lint = require 'lint'
lint.linters_by_ft = {
  markdown = { 'markdownlint' },
}

local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
local timer = vim.uv.new_timer()
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = lint_augroup,
  callback = function(event)
    -- Avoid linting nonmodifiable Markdown buffers such as LSP documentation.
    if not vim.bo[event.buf].modifiable then return end
    timer:stop()
    timer:start(
      100,
      0,
      vim.schedule_wrap(function()
        if vim.api.nvim_buf_is_valid(event.buf) then vim.api.nvim_buf_call(event.buf, lint.try_lint) end
      end)
    )
  end,
})

vim.schedule(function()
  if vim.bo.modifiable then lint.try_lint() end
end)
