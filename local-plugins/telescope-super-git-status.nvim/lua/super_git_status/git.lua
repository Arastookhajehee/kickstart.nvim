local M = {}

local function notify_callback(callback, ...)
  local args = { n = select('#', ...), ... }
  vim.schedule(function() callback(unpack(args, 1, args.n)) end)
end

local function run(args, cwd)
  local ok, result = pcall(function() return vim.system(args, { cwd = cwd, text = true }):wait() end)
  if not ok then return nil, tostring(result) end
  if result.code ~= 0 then return nil, vim.trim(result.stderr or '') end
  return vim.trim(result.stdout or '')
end

local function path_key(path)
  path = vim.uv.fs_realpath(path) or vim.fs.normalize(path)
  return vim.fn.has 'win32' == 1 and path:lower() or path
end

local function repository_root(cwd)
  local root, err = run({ 'git', 'rev-parse', '--show-toplevel' }, cwd)
  if not root then return nil, err ~= '' and err or 'Not inside a Git worktree' end

  root = vim.fs.normalize(root)
  while true do
    local parent, parent_err = run({ 'git', 'rev-parse', '--show-superproject-working-tree' }, root)
    if not parent then return nil, parent_err end
    if parent == '' then return root end
    root = vim.fs.normalize(parent)
  end
end

local function discover_repositories(root)
  local repositories = { { root = root, label = '.' } }
  local queue = { repositories[1] }
  local seen = { [path_key(root)] = true }
  local index = 1

  while index <= #queue do
    local repository = queue[index]
    index = index + 1
    local gitmodules = vim.fs.joinpath(repository.root, '.gitmodules')

    if vim.uv.fs_stat(gitmodules) then
      local output = run({ 'git', 'config', '--file', gitmodules, '--get-regexp', '^submodule\\..*\\.path$' }, repository.root)
      for line in (output or ''):gmatch '[^\r\n]+' do
        local relative = line:match '^%S+%s+(.+)$'
        if relative then
          local candidate = vim.fs.normalize(vim.fs.joinpath(repository.root, relative))
          if vim.uv.fs_stat(candidate) then
            local actual = run({ 'git', 'rev-parse', '--show-toplevel' }, candidate)
            if actual then
              actual = vim.fs.normalize(actual)
              local key = path_key(actual)
              if not seen[key] then
                seen[key] = true
                local label = vim.fs.relpath(root, actual) or actual
                local child = { root = actual, label = label:gsub('\\', '/') }
                repositories[#repositories + 1] = child
                queue[#queue + 1] = child
              end
            end
          end
        end
      end
    end
  end

  table.sort(repositories, function(a, b) return a.label < b.label end)
  return repositories
end

local function parse_status(output, repository)
  local entries = {}
  local records = vim.split(output or '', '\0', { plain = true, trimempty = true })
  local index = 1

  while index <= #records do
    local record = records[index]
    local status = record:sub(1, 2)
    local relative = record:sub(4)

    if relative ~= '' then
      entries[#entries + 1] = {
        status = status,
        relative_path = relative,
        path = vim.fs.normalize(vim.fs.joinpath(repository.root, relative)),
        repo_root = repository.root,
        repo_label = repository.label,
      }
    end

    if status:find '[RC]' then index = index + 1 end
    index = index + 1
  end

  return entries
end

function M.collect(cwd, callback)
  local root, root_err = repository_root(cwd)
  if not root then
    notify_callback(callback, nil, nil, root_err)
    return
  end

  local repositories = discover_repositories(root)
  local entries = {}
  local errors = {}
  local pending = #repositories

  for _, repository in ipairs(repositories) do
    vim.system({ 'git', 'status', '--porcelain=v1', '-z', '--untracked-files=all', '--', '.' }, {
      cwd = repository.root,
    }, function(result)
      vim.schedule(function()
        if result.code == 0 then
          vim.list_extend(entries, parse_status(result.stdout, repository))
        else
          errors[#errors + 1] = ('%s: %s'):format(repository.label, vim.trim(result.stderr or 'git status failed'))
        end

        pending = pending - 1
        if pending == 0 then
          table.sort(entries, function(a, b)
            if a.repo_label == b.repo_label then return a.relative_path < b.relative_path end
            return a.repo_label < b.repo_label
          end)
          callback(entries, { root = root, repositories = repositories, errors = errors })
        end
      end)
    end)
  end
end

function M.toggle_stage(entry, callback)
  local args
  if entry.status:sub(2, 2) == ' ' then
    args = { 'git', 'restore', '--staged', '--', entry.relative_path }
  else
    args = { 'git', 'add', '--', entry.relative_path }
  end

  vim.system(args, { cwd = entry.repo_root, text = true }, function(result) notify_callback(callback, result.code == 0, vim.trim(result.stderr or '')) end)
end

return M
