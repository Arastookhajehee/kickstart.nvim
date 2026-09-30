local M = {}

if vim.fn.has 'win32' ~= 1 then
  M.available = false
  return M
end

local ok, ffi = pcall(require, 'ffi')
if not ok then
  M.available = false
  return M
end

ffi.cdef [[
typedef void *HWND;
typedef int BOOL;
typedef unsigned short WCHAR;
typedef struct { long left; long top; long right; long bottom; } RECT;
typedef struct { long x; long y; } POINT;

HWND GetForegroundWindow(void);
int GetClassNameW(HWND hWnd, WCHAR *lpClassName, int nMaxCount);
BOOL GetClientRect(HWND hWnd, RECT *lpRect);
BOOL ClientToScreen(HWND hWnd, POINT *lpPoint);
BOOL GetCursorPos(POINT *lpPoint);
BOOL SetCursorPos(int X, int Y);
]]

local user32 = ffi.load 'user32'
M.available = true

local function window_class(hwnd)
  local buffer = ffi.new 'WCHAR[256]'
  local length = user32.GetClassNameW(hwnd, buffer, 256)
  if length == 0 then return nil end

  local chars = {}
  for index = 0, length - 1 do
    chars[#chars + 1] = string.char(buffer[index])
  end
  return table.concat(chars)
end

function M.foreground_client(expected_class)
  local hwnd = user32.GetForegroundWindow()
  if hwnd == nil or window_class(hwnd) ~= expected_class then return nil end

  local rect = ffi.new 'RECT[1]'
  local origin = ffi.new 'POINT[1]'
  if user32.GetClientRect(hwnd, rect) == 0 or user32.ClientToScreen(hwnd, origin) == 0 then return nil end

  return {
    x = tonumber(origin[0].x),
    y = tonumber(origin[0].y),
    width = tonumber(rect[0].right - rect[0].left),
    height = tonumber(rect[0].bottom - rect[0].top),
  }
end

function M.cursor_position()
  local point = ffi.new 'POINT[1]'
  if user32.GetCursorPos(point) == 0 then return nil end
  return { x = tonumber(point[0].x), y = tonumber(point[0].y) }
end

function M.set_cursor_position(x, y) return user32.SetCursorPos(x, y) ~= 0 end

return M
