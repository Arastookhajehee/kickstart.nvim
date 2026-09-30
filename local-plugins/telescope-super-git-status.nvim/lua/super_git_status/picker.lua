local M = {}

local git = require 'super_git_status.git'

local status_icons = {
  ['A'] = { '+', 'TelescopeResultsDiffAdd' },
  ['C'] = { '>', 'TelescopeResultsDiffChange' },
  ['D'] = { '-', 'TelescopeResultsDiffDelete' },
  ['M'] = { '~', 'TelescopeResultsDiffChange' },
  ['R'] = { '>', 'TelescopeResultsDiffChange' },
  ['U'] = { '!', 'TelescopeResultsDiffAdd' },
  ['?'] = { '?', 'TelescopeResultsDiffUntracked' },
}

local function status_cell(status)
  local icon = status_icons[status]
  return icon and { icon[1], icon[2] } or { ' ' }
end

local function finder(entries)
  local displayer = require('telescope.pickers.entry_display').create {
    separator = '',
    items = { { width = 2 }, { width = 2 }, { remaining = true } },
  }

  return require('telescope.finders').new_table {
    results = entries,
    entry_maker = function(item)
      return {
        value = item.relative_path,
        ordinal = ('%s %s %s'):format(item.repo_label, item.relative_path, item.status),
        display = function(entry)
          return displayer {
            status_cell(entry.status:sub(1, 1)),
            status_cell(entry.status:sub(2, 2)),
            ('[%s] %s'):format(entry.repo_label, entry.relative_path:gsub('[\r\n]', ' ')),
          }
        end,
        filename = item.path,
        path = item.path,
        status = item.status,
        relative_path = item.relative_path,
        repo_root = item.repo_root,
        repo_label = item.repo_label,
      }
    end,
  }
end

local function previewer()
  local conf = require('telescope.config').values
  local previewers = require 'telescope.previewers'
  local preview_utils = require 'telescope.previewers.utils'

  return previewers.new_buffer_previewer {
    title = 'Git File Diff Preview',
    dyn_title = function(_, entry) return ('[%s] %s'):format(entry.repo_label, entry.relative_path) end,
    get_buffer_by_name = function(_, entry) return entry.repo_root .. '::' .. entry.relative_path .. '::' .. entry.status end,
    define_preview = function(self, entry)
      if (entry.status == '??' or entry.status == 'A ') and vim.uv.fs_stat(entry.path) then
        conf.buffer_previewer_maker(entry.path, self.state.bufnr, {
          bufname = self.state.bufname,
          winid = self.state.winid,
        })
        return
      end

      preview_utils.job_maker({ 'git', '--no-pager', 'diff', 'HEAD', '--', entry.relative_path }, self.state.bufnr, {
        value = entry.repo_root .. '::' .. entry.relative_path .. '::' .. entry.status,
        bufname = self.state.bufname,
        cwd = entry.repo_root,
        callback = function(bufnr)
          if vim.api.nvim_buf_is_valid(bufnr) then preview_utils.highlighter(bufnr, 'diff') end
        end,
      })
    end,
  }
end

local function report_errors(context)
  if #context.errors == 0 then return end
  vim.notify(table.concat(context.errors, '\n'), vim.log.levels.WARN, { title = 'Super Git Status' })
end

local function open_picker(entries, context, opts)
  local action_state = require 'telescope.actions.state'
  local picker

  local function refresh(prompt_bufnr)
    local row = picker:get_selection_row()
    git.collect(context.root, function(new_entries, new_context, err)
      if err then
        vim.notify(err, vim.log.levels.ERROR, { title = 'Super Git Status' })
        return
      end
      if not vim.api.nvim_buf_is_valid(prompt_bufnr) then return end

      context = new_context
      report_errors(context)
      picker:refresh(finder(new_entries), { reset_prompt = false })
      picker:set_selection(row)
    end)
  end

  picker = require('telescope.pickers').new(opts, {
    prompt_title = 'Superproject Git Status',
    finder = finder(entries),
    previewer = previewer(),
    sorter = require('telescope.config').values.file_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      local function toggle_stage()
        local entry = action_state.get_selected_entry()
        if not entry then return end

        git.toggle_stage(entry, function(ok, err)
          if not ok then
            vim.notify(err ~= '' and err or 'Unable to update the Git index', vim.log.levels.ERROR, { title = 'Super Git Status' })
            return
          end
          refresh(prompt_bufnr)
        end)
      end

      map({ 'i', 'n' }, '<Tab>', toggle_stage)
      return true
    end,
  })
  picker:find()
end

function M.open(opts)
  opts = opts or {}
  git.collect(opts.cwd or vim.uv.cwd(), function(entries, context, err)
    if err then
      vim.notify(err, vim.log.levels.ERROR, { title = 'Super Git Status' })
      return
    end

    report_errors(context)
    if #entries == 0 then
      vim.notify('No changes found', vim.log.levels.INFO, { title = 'Super Git Status' })
      return
    end
    open_picker(entries, context, opts)
  end)
end

return M
