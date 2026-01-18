-- ┌──────────────────────┐
-- │ CSS LSP config       │
-- └──────────────────────┘
--
-- This file contains configuration of 'cssls' language server.
-- Source: https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/cssls.lua
--
-- It is used by `:h vim.lsp.enable()` and `:h vim.lsp.config()`.
return {
  settings = {
    css = {
      validate = true,
    },
    scss = {
      validate = true,
    },
    less = {
      validate = true,
    },
  },
}
