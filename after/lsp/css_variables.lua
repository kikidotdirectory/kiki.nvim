-- ┌──────────────────────────────┐
-- │ CSS Variables LSP config     │
-- └──────────────────────────────┘
--
-- This file contains configuration of 'css_variables' language server.
-- Source: https://github.com/comeditech/css-variables-language-server
--
-- It is used by `:h vim.lsp.enable()` and `:h vim.lsp.config()`.
-- Fixes EPERM errors when scanning directories like Trash
return {
  on_attach = function(client, buf_id)
    -- Disable workspace/didChangeWorkspaceFolders capability to avoid warnings
    -- about mismatched dynamicRegistration settings
    if client.server_capabilities then
      client.server_capabilities.workspace = nil
    end
  end,
  init_options = {
    -- Prevent scanning of system directories that may cause permission errors
    exclude = {
      ".Trash",
      ".Trash-*",
      "node_modules",
    },
  },
}
