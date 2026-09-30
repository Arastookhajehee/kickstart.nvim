local M = {}

function M.target(client, grid, cursor, opts, calibration)
  local width = client.width - 2 * opts.padding_x
  local height = client.height - opts.top_offset - 2 * opts.padding_y
  if width <= 0 or height <= 0 or grid.columns <= 0 or grid.lines <= 0 then return nil end

  local cell_width = width / grid.columns
  local cell_height = height / grid.lines
  local x = client.x + opts.padding_x + (cursor.col - 0.5) * cell_width + calibration.x
  local y = client.y + opts.top_offset + opts.padding_y + (cursor.row - 0.5) * cell_height + calibration.y

  return {
    x = math.floor(x + 0.5),
    y = math.floor(y + 0.5),
    cell_width = cell_width,
    cell_height = cell_height,
  }
end

return M
