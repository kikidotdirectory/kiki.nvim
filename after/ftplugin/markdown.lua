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

vim.keymap.set("n", "<localleader>i", function()
	Snacks.image.doc.hover()
end, { buffer = true, desc = "Show image at cursor" })

vim.keymap.set("n", "<Esc>", function()
	Snacks.image.doc.hover_close()
	vim.cmd("nohlsearch")
end, { buffer = true, desc = "Close image hover / clear search highlight" })

-- markdown-plus keymaps to be layered on top of keymaps defined in plugin/40_plugins.lua
local function in_list_context(kind)
	return function()
		return require("markdown-plus").in_list_context(kind)
	end
end

local markdown_plus_indent = {
	condition = in_list_context("indent"),
	action = function()
		return "<Plug>(MarkdownPlusListIndent)"
	end,
}
local markdown_plus_outdent = {
	condition = in_list_context("outindent"),
	action = function()
		return "<Plug>(MarkdownPlusListOutdent)"
	end,
}
local markdown_plus_enter = {
	condition = in_list_context("enter"),
	action = function()
		return "<Plug>(MarkdownPlusListEnter)"
	end,
}

local MiniKeymap = require("mini.keymap")
MiniKeymap.map_multistep("i", "<Tab>", { "pmenu_next", markdown_plus_indent }, { buffer = true })
MiniKeymap.map_multistep("i", "<S-Tab>", { "pmenu_prev", markdown_plus_outdent }, { buffer = true })
MiniKeymap.map_multistep("i", "<CR>", { "pmenu_accept", markdown_plus_enter, "minipairs_cr" }, { buffer = true })
