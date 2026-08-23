local function copy_devenv_edit_command()
  local file = vim.fn.expand '%:p'
  if file == '' then
    vim.notify('No file path for current buffer', vim.log.levels.WARN)
    return
  end

  local line = vim.fn.mode():match '[vV"]' and math.min(vim.fn.line "'<", vim.fn.line "'>") or vim.fn.line '.'
  local command = ('devenv /edit %s /command "edit.goto %d"'):format(file, line)

  vim.fn.setreg('+', command)
  vim.notify('Copied devenv edit command')
end

vim.keymap.set({ 'n', 'x' }, '<leader>vs', copy_devenv_edit_command, { desc = 'Copy devenv edit command' })
