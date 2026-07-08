local add = vim.pack.add
local now_if_args, later, on_filetype = Config.now_if_args, Config.later, Config.on_filetype

-- Tree-sitter ================================================================
now_if_args(function()
	-- Define hook to update tree-sitter parsers after plugin is updated
	local ts_update = function()
		vim.cmd("TSUpdate")
	end
	Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

	add({
		"https://github.com/nvim-treesitter/nvim-treesitter",
		"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
	})

	-- Define which languages to be automatically installed & used
	local languages = {
		"lua",
		"vimdoc",
		"markdown",
		"javascript",
		"typescript",
		"html",
		"css",
		"vento",
		"svelte",
		"yaml",
		"json",
	}

	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, languages)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	-- Enable tree-sitter after opening a file for a target language
	local filetypes = {}
	for _, lang in ipairs(languages) do
		for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
			table.insert(filetypes, ft)
		end
	end
	local ts_start = function(ev)
		vim.treesitter.start(ev.buf)
	end
	_G.Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end)

-- Language servers ===========================================================

now_if_args(function()
	add({ "https://github.com/neovim/nvim-lspconfig" })
	vim.lsp.enable({
		--lua
		"lua_ls",
		-- ts/js
		"vtsls",
		"denols",
		-- svelte
		"svelte",
		-- css
		"cssls",
		"css_variables",
		-- html
		"superhtml",
		"emmet_language_server",
		-- json
		"jsonls",
		-- python
		"pylsp",
		-- bash
		"bashls",
	})
end)

-- Formatting =================================================================

later(function()
	add({ "https://github.com/stevearc/conform.nvim" })
	require("conform").setup({
		default_format_opts = {
			-- Allow formatting from LSP server if no dedicated formatter is available
			lsp_format = "fallback",
		},
		-- Map of filetype to formatters
		-- Corresponding CLI tool needs to be installed
		formatters_by_ft = {
			lua = { "stylua" },
			html = { "superhtml" },
			javascript = { "dprint" },
			typescript = { "dprint" },
			json = { "dprint" },
			css = { "dprint" },
			vento = { "dprint" },
			svelte = { "prettierd", "prettier", stop_after_first = true },
			python = { "black" },
			bash = { "shfmt" },
		},
	})
end)

-- Snippets ===================================================================

later(function()
	add({ "https://github.com/rafamadriz/friendly-snippets" })
end)

-- Git Integration ============================================================

later(function()
	add({ "https://github.com/aspeddro/gitui.nvim" })
	require("gitui").setup()
end)

-- Appearance =================================================================

add({ "https://github.com/neanias/everforest-nvim" })
vim.cmd("colorscheme everforest")

add({ "https://github.com/nvim-lua/plenary.nvim" })
add({ { src = "https://github.com/obsidian-nvim/obsidian.nvim", version = "*" } })

add({ "https://github.com/jedrzejboczar/exrc.nvim" })
require("exrc").setup()

add({ "https://github.com/folke/snacks.nvim" })
require("snacks").setup()

add({ "https://github.com/coder/claudecode.nvim" })
require("claudecode").setup({
	terminal = {
		snacks_win_opts = {
			keys = {
				claude_hide_ctrl = {
					"<C-,>",
					function(self)
						self:hide()
					end,
					mode = "t",
					desc = "Hide (Ctrl+,)",
				},
			},
		},
	},
})

vim.keymap.set({ "n", "x" }, "<C-,>", "<cmd>ClaudeCodeFocus<cr>", { desc = "Claude Code (Ctrl+,)" })
