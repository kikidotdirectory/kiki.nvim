-- Enable wrap for window
vim.cmd("setlocal wrap")

-- disable MiniHipatterns
vim.b.minihipatterns_disable = true

-- disable MiniPairs, handled by obsidian
vim.b.minipairs_disable = true

-- Fold with tree-sitter
vim.cmd("setlocal foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()")

-- Disable built-in `gO` mapping in favor of 'mini.basics'
vim.keymap.del("n", "gO", { buffer = 0 })

-- Conceal markdown syntax for readability
vim.opt.conceallevel = 2

-- Navigate through visual lines in .md files
vim.keymap.set("n", "<Down>", "gj", { buffer = true })
vim.keymap.set("n", "<Up>", "gk", { buffer = true })

-- Trim whitespace on save in lieu of proper formatter
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		MiniTrailspace.trim()
	end,
})

-- Set markdown-specific surrounding in 'mini.surround'
vim.b.minisurround_config = {
	custom_surroundings = {
		-- Markdown link. Common usage:
		-- `saiwL` + [type/paste link] + <CR> - add link
		-- `sdL` - delete link
		-- `srLL` + [type/paste link] + <CR> - replace link
		L = {
			input = { "%[().-()%]%(.-%)" },
			output = function()
				local link = require("mini.surround").user_input("Link: ")
				return { left = "[", right = "](" .. link .. ")" }
			end,
		},
	},
}

-- Treat any `docs/` directory as an ephemeral Obsidian workspace.
-- See 'lua/project_docs.lua'.
local project_docs = require("project_docs")

vim.api.nvim_create_autocmd("BufEnter", {
	buffer = 0,
	callback = function()
		local docs_root = vim.api.nvim_buf_get_name(0):match("^(.*/docs)/")
		if docs_root then
			project_docs.set_docs_workspace(docs_root)
		end
	end,
})

vim.keymap.set("n", "<localleader>p", "<Plug>(md-render-preview)", { desc = "Markdown preview (toggle)" })
vim.keymap.set("n", "<localleader>P", "<CMD>vert MdRender split<CR>", { desc = "Markdown preview in split" })

