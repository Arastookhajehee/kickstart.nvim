vim.pack.add {
  {
    src = 'https://github.com/ThePrimeagen/harpoon',
    version = 'harpoon2',
  },
}

local harpoon = require 'harpoon'
harpoon:setup {}

local function open_telescope()
  local list = harpoon:list()
  local paths = {}

  for index = 1, list:length() do
    local item = list.items[index]
    if item then table.insert(paths, item.value) end
  end

  local conf = require('telescope.config').values
  require('telescope.pickers')
    .new({}, {
      prompt_title = 'Harpoon',
      finder = require('telescope.finders').new_table { results = paths },
      previewer = conf.file_previewer {},
      sorter = conf.file_sorter {},
    })
    :find()
end

vim.keymap.set('n', '<leader>ja', function() harpoon:list():add() end, { desc = '[J]ump [A]dd file' })
vim.keymap.set('n', '<leader>jl', open_telescope, { desc = '[J]ump [L]ist (Telescope)' })
vim.keymap.set('n', '<leader>jn', function() harpoon:list():next { ui_nav_wrap = true } end, { desc = '[J]ump [N]ext' })
vim.keymap.set('n', '<leader>jp', function() harpoon:list():prev { ui_nav_wrap = true } end, { desc = '[J]ump [P]revious' })

for index = 1, 4 do
  local target = index
  vim.keymap.set('n', '<leader>j' .. target, function() harpoon:list():select(target) end, { desc = '[J]ump to file ' .. target })
end
