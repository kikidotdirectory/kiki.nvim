return {
  on_attach = function()
    -- Map 'ts' fenced code blocks in markdown to TypeScript so denols can
    -- provide LSP features (hover, diagnostics) inside those blocks.
    vim.g.markdown_fenced_languages = { "ts=typescript" }
  end,
}
