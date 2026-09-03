local add = vim.pack.add
local now_if_args, later, on_filetype = Config.now_if_args, Config.later, Config.on_filetype

-- Plugins below are grouped into three tiers:
-- - Necessary  - core editing/language tooling the config depends on
-- - Functional - features that add specific workflows (git, notes, AI, etc.)
-- - Aesthetic  - looks and feel (colorscheme, UI chrome)
--
-- Within each tier, plugins load via the helpers from 'init.lua':
-- `now_if_args` runs eagerly only when Neovim opens with a file argument,
-- `later` defers until Neovim is idle.

-- Core ========================================================================

-- Tree-sitter --
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
		"php",
		"blade",
		"sql",
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

-- Language servers --
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
		-- bash
		"bashls",
		-- swift
		"sourcekit",
		-- typst
		"tinymist",
		--sql
		"sqls",
	})
end)

-- Install LSP/formatting/linter executables ==================================
now_if_args(function()
	add({ "https://github.com/mason-org/mason.nvim" })
	require("mason").setup()
end)

-- Formatting --
-- Maps filetypes to formatter CLIs; each formatter must be installed separately.
later(function()
	add({ "https://github.com/stevearc/conform.nvim" })
	require("conform").setup({
		default_format_opts = {
			-- Allow formatting from LSP server if no dedicated formatter is available
			lsp_format = "fallback",
		},
		format_on_save = {
			-- Fall through to the next formatter/LSP instead of blocking the save
			-- if the configured one takes too long
			timeout_ms = 500,
			lsp_format = "fallback",
		},
		-- Map of filetype to formatters
		-- Corresponding CLI tool needs to be installed
		formatters_by_ft = {
			lua = { "stylua" },
			html = { "dprint", "superhtml", stop_after_first = true },
			javascript = { "dprint" },
			typescript = { "dprint" },
			json = { "dprint" },
			css = { "dprint" },
			vento = { "dprint" },
			-- svelte = { "prettierd", "prettier", stop_after_first = true },
			svelte = { "dprint" },
			bash = { "shfmt" },
			swift = { "swift" },
			sql = { "sqlfmt" },
		},
	})
end)

-- Functional ------------------------------------------------------------------

-- Snippets
later(function()
	add({ "https://github.com/rafamadriz/friendly-snippets" })
end)

-- Git integration
later(function()
	add({ "https://github.com/aspeddro/gitui.nvim" })
	require("gitui").setup()
end)

-- Note-taking (Obsidian)
later(function()
	add({ "https://github.com/nvim-lua/plenary.nvim" }) -- dependency --
	add({ { src = "https://github.com/obsidian-nvim/obsidian.nvim", version = "v3.16.6" } })
	require("obsidian").setup({
		legacy_commands = false,
		note_id_func = require("obsidian.builtin").title_id,
		footer = {
			enabled = false,
			separator = false,
		},
		checkbox = {
			enabled = true,
			create_new = true,
			order = { " ", "~", "x" },
		},
		workspaces = {
			{
				name = "meandering",
				path = "~/Documents/meandering",
			},
		},
		templates = {
			folder = "templates",
		},
		picker = {
			name = "mini.pick",
		},
	})

	vim.api.nvim_create_autocmd("CmdlineChanged", {
		callback = function()
			local cmdline = vim.fn.getcmdline()
			if vim.fn.getcmdtype() ~= ":" then
				return
			end
			if not cmdline:match("^Obsidian[A-Za-z0-9]*$") then
				return
			end
			vim.fn.wildtrigger()
		end,
	})
end)

-- exrc (Per-project configuration)
-- Loads project-local config files (e.g. .nvim.lua) when trusted
add({ "https://github.com/jedrzejboczar/exrc.nvim" })
require("exrc").setup()

-- Claude Code integration
later(function()
	add({ "https://github.com/folke/snacks.nvim" }) -- dependency --
	require("snacks").setup()
	add({ "https://github.com/coder/claudecode.nvim" })
	require("claudecode").setup({
		-- Focus the Claude terminal after a successful send instead of leaving
		-- focus (and thus insert mode, via `terminal.auto_insert`) in the source buffer.
		focus_after_send = true,
		diff_opts = {
			open_in_new_tab = true,
			keep_terminal_focus = true,
		},
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
					claude_switch_ctrl = {
						"<C-.>",
						function()
							vim.cmd("wincmd p")
						end,
						mode = "t",
						desc = "Switch to buffer (Ctrl+.)",
					},
				},
			},
		},
	})

	-- Show the Claude terminal without focusing it (creates/reveals, keeps cursor put)
	vim.api.nvim_create_user_command("ClaudeCodeShow", function()
		require("claudecode.terminal").ensure_visible()
	end, { desc = "Show Claude Code terminal without focusing it" })
end)

later(function()
	add({ "https://github.com/akinsho/toggleterm.nvim" })
	require("toggleterm").setup({
		open_mapping = [[<c-\>]],
		autochdir = true,
		Normal = {
			guibg = "bg",
		},
	})
end)

-- -- typescript errors
-- later(function()
-- 	add({ "https://github.com/dmmulroy/ts-error-translator.nvim" })
-- 	require("ts-error-translator").setup()
-- end)

-- Aesthetic -------------------------------------------------------------------
-- Colorscheme
add({ "https://github.com/neanias/everforest-nvim" })
vim.cmd("colorscheme everforest")
