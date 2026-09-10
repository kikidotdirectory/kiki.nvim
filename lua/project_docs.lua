-- Registers any project's `docs/` directory as an ephemeral Obsidian
-- workspace, independent of the vaults registered in 'plugin/40_plugins.lua'.
-- Used by the `BufEnter` autocommand in 'after/ftplugin/markdown.lua'.

local M = {}

-- `strict = true` pins the workspace root to `docs_root` itself rather than
-- searching upward for a `.obsidian/` folder. See `:h obsidian.Workspace`
-- and `:h Workspace.set()`.
--
-- Registering with `Workspace.set()` alone isn't enough: obsidian.nvim's own
-- `BufEnter` handler (`obsidian/autocmds.lua`) gates *all* of its keymaps and
-- the `enter_note` callback behind `api.find_workspace(file)`, which only
-- searches the plural `Obsidian.workspaces` list built once from `setup()`'s
-- `workspaces` table -- it never looks at the singular `Obsidian.workspace`
-- pointer that `Workspace.set()` reassigns. So `docs_root` must be inserted
-- into `Obsidian.workspaces` itself, or obsidian's own `BufEnter` callback
-- keeps bailing out early for every file under it and none of its mappings
-- fire.
---@param docs_root string

function M.set_docs_workspace(docs_root, attempts)
	local attempts_left = attempts or 20

	local ok, workspace = pcall(require, "obsidian.workspace")
	if not ok then
		if attempts_left > 0 then
			vim.defer_fn(function()
				M.set_docs_workspace(docs_root, attempts_left - 1)
			end, 250)
		end
		return
	end

	local spec = {
		name = "docs",
		path = docs_root,
		strict = true,
		overrides = {
			-- force disable to avoid creating erroneous templates/ directories
			templates = {
				enabled = false,
			},
		},
	}
	local ws = workspace.new(spec)

	if not ws then
		return
	end

	local existing
	for _, registered in ipairs(Obsidian.workspaces or {}) do
		if tostring(registered.root) == tostring(ws.root) then
			existing = registered
			break
		end
	end

	if existing then
		ws = existing
	else
		table.insert(Obsidian.workspaces, ws)
	end

	if Obsidian.workspace ~= ws then
		workspace.set(ws)
	end
end

return M
