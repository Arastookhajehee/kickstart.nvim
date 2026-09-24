local mermaid_css = vim.fn.stdpath 'cache' .. '/diagram-mermaid.css'

local css = {
  [[text,]],
  [[.nodeLabel,]],
  [[.edgeLabel {]],
  [[  font-size: 14px !important;]],
  [[  font-family: "0xProto Nerd Font Mono", monospace !important;]],
  [[}]],
  [[]],
  [[.node foreignObject {]],
  [[  overflow: visible !important;]],
  [[}]],
  [[]],
  [[.node .label,]],
  [[.node .label > div,]],
  [[.node .label > span,]],
  [[.nodeLabel {]],
  [[  margin: 0 !important;]],
  [[  padding: 0 !important;]],
  [[  line-height: 1.05 !important;]],
  [[  display: block !important;]],
  [[  width: 100% !important;]],
  [[  text-align: center !important;]],
  [[  white-space: pre-line !important;]],
  [[  box-sizing: border-box !important;]],
  [[}]],
  [[]],
  [[.node rect {]],
  [[  rx: 10px !important;]],
  [[  ry: 10px !important;]],
  [[}]],
}
local existing = vim.fn.filereadable(mermaid_css) == 1 and vim.fn.readfile(mermaid_css) or {}
if not vim.deep_equal(existing, css) then vim.fn.writefile(css, mermaid_css) end

require('diagram').setup {
  integrations = {
    require 'diagram.integrations.markdown',
    require 'diagram.integrations.neorg',
  },

  renderer_options = {
    mermaid = {
      theme = 'dark',
      background = 'transparent',

      cli_args = {
        '--width',
        '600',
        '--scale',
        '4',
        '--cssFile',
        mermaid_css,
      },

      config = {
        flowchart = {
          htmlLabels = true,
          useMaxWidth = false,
          padding = 2,
        },
      },
    },
  },
}
