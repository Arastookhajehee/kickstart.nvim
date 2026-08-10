vim.pack.add {
  'https://github.com/benfowler/telescope-luasnip.nvim',
  'https://github.com/rafamadriz/friendly-snippets',
}

require('luasnip.loaders.from_vscode').lazy_load()

local ls = require 'luasnip'
ls.add_snippets('markdown', {
  ls.parser.parse_snippet(
    { trig = 'mermaid-flowchart', name = 'Mermaid flowchart', dscr = 'Mermaid flowchart diagram template' },
    [=[```mermaid
flowchart TD
    A[${1:Start}] --> B{${2:Decision}}
    B -->|${3:Yes}| C[${4:Do thing}]
    B -->|${5:No}| D[${6:Stop}]
$0
```]=]
  ),
  ls.parser.parse_snippet(
    { trig = 'mermaid-sequence', name = 'Mermaid sequence', dscr = 'Mermaid sequence diagram template' },
    [=[```mermaid
sequenceDiagram
    participant A as ${1:Actor}
    participant B as ${2:System}
    A->>B: ${3:Request}
    B-->>A: ${4:Response}
$0
```]=]
  ),
  ls.parser.parse_snippet(
    { trig = 'mermaid-class', name = 'Mermaid class diagram', dscr = 'Mermaid class diagram template' },
    [=[```mermaid
classDiagram
    class ${1:ClassName} {
        +${2:string} ${3:Property}
        +${4:Method}()
    }
$0
```]=]
  ),
  ls.parser.parse_snippet(
    { trig = 'mermaid-state', name = 'Mermaid state diagram', dscr = 'Mermaid state diagram template' },
    [=[```mermaid
stateDiagram-v2
    state "${1:Idle}" as idle
    state "${2:Running}" as running
    [*] --> idle
    idle --> running: ${3:start}
    running --> idle: ${4:stop}
    idle --> [*]
$0
```]=]
  ),
})

local ok, telescope = pcall(require, 'telescope')
if ok then telescope.load_extension 'luasnip' end

vim.keymap.set('n', '<leader>ls', function() require('telescope').extensions.luasnip.luasnip {} end, { desc = '[L]uaSnip [S]nippets' })
