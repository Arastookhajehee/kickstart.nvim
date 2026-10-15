# Environment variables

All variables are optional. Set only those needed by your workflows.

| Variable | Purpose | Default |
| --- | --- | --- |
| `NVIM_OS_TYPE` | Override platform-sensitive plugin behavior (`WIN`, `WSL`, `LINUX`, or `TERMUX`) | Native detection |
| `NVIM_ZOTERO_DB_PATH` | Path to the Zotero SQLite database | Zotcite disabled |
| `NVIM_LAYOUT` | Set to `HORIZONTAL` for Telescope's horizontal layout | Vertical layout |
| `NVIM_WINDOWS_NETCOREDBG` | WSL path to a Windows `netcoredbg.exe` | Scoop `current` path when `WIN_USERNAME` is set |
| `WIN_USERNAME` | Windows username used for Scoop debugger discovery from WSL | Windows attachment disabled |
| `OPENCODE_PORT` | OpenCode server port | `40801` |
| `OPENCODE_URL` | Complete OpenCode server URL | Localhost with `OPENCODE_PORT` |
| `NVIM_APPNAME` | Select an alternate Neovim config and data directory | `nvim` |

## PowerShell examples

```powershell
$env:NVIM_OS_TYPE = 'WIN'
$env:NVIM_ZOTERO_DB_PATH = 'C:/Users/you/Zotero/zotero.sqlite'
$env:NVIM_LAYOUT = 'HORIZONTAL'
```

## WSL examples

```bash
export NVIM_OS_TYPE=WSL
export NVIM_ZOTERO_DB_PATH=/mnt/c/Users/you/Zotero/zotero.sqlite
export WIN_USERNAME=you
export NVIM_WINDOWS_NETCOREDBG=/mnt/c/tools/netcoredbg/netcoredbg.exe
```

Inline Markdown images are disabled on native Windows because the configured
image backend requires terminal graphics support that is used only on non-Windows
platforms.
