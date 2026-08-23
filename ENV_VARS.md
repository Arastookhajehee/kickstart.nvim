# Environment Vars

The following vars ensure plugins load(not load) correctly on the OS type.

## OS Type

Not all plugins are supported for windows.
For example, inline Markdown image rendering is no supported on windows.

```bash
NVIM_OS_TYPE = {'WIN', 'WSL', 'LINUX', 'TERMUX'}
```

## Zotero database file path

```bash
# Windows
NVIM_ZOTERO_DB_PATH = {C:/Users/<USERPROFILE>/Zotero/zotero.sqlite }
# WSL
NVIM_ZOTERO_DB_PATH = {/mnt/c/Users/<USERPROFILE>/Zotero/zotero.sqlite }
```
