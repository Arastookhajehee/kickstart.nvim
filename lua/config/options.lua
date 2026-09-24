vim.filetype.add {
  extension = {
    razor = 'razor',
    cshtml = 'razor',
  },
  pattern = {
    ['.*%.uxml'] = 'xml',
    ['.*%.uss'] = 'css',
    ['%.env.*'] = 'sh',
  },
  filename = {
    ['.env'] = 'sh',
  },
}

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.confirm = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.incsearch = true
vim.opt.isfname:append '@-@'
vim.opt.colorcolumn = '100,120'
vim.opt.spelllang = 'en_us'
vim.opt.spell = true

if vim.env.NVIM_OS_TYPE == 'WIN' or vim.fn.has 'win32' == 1 then
  vim.opt.shell = 'pwsh.exe'
  vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
  vim.opt.shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
  vim.opt.shellpipe = '2>&1 | Tee-Object %s; exit $LastExitCode'
  vim.opt.shellquote = ''
  vim.opt.shellxquote = ''
end

vim.schedule(function() vim.opt.clipboard = 'unnamedplus' end)
