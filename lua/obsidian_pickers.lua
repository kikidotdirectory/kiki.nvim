-- Obsidian tag-based note pickers, used by the '<Leader>fo' mappings defined
-- in 'plugin/20_keymaps.lua'. Kept as a `require()`d module (rather than in
-- 'plugin/') since this returns a table of functions, not something that
-- needs to run at startup.

local M = {}

-- Build a picker over notes tagged `tag`. Add a new tag mapping with:
--   nmap_leader('foX', obsidian_pickers.make_pick_tag('x'), 'Notes tagged #x')
-- Pass `new_from_template = true` to append a trailing entry that creates a
-- new note from a template instead of opening an existing one.
-- Pass `template = 'name.md'` (a filename inside the templates dir) to skip
-- the templates picker and use that template directly.
-- Pass `omit_subtags = { 'done', 'archived' }` to exclude notes also tagged
-- with any of these subtags (e.g. `#project/done`). Defaults to none.
function M.make_pick_tag(tag, opts)
	opts = opts or {}
	local omit_subtags = opts.omit_subtags or {}
	return function()
		local search = require("obsidian.search")
		local picker = require("obsidian.picker").get()
		local api = require("obsidian.api")

		local handled = false
		search.find_tags_async(tag, function(tag_locations)
			-- NOTE: obsidian.nvim's find_tags_async can invoke this callback twice
			-- when the search finds no matches (missing `return` after an early
			-- `callback {}` on nonzero exit code). Guard against opening the
			-- picker twice, which force-closes the first one immediately.
			if handled then
				return
			end
			handled = true

			local omit_tags = {}
			for _, subtag in ipairs(omit_subtags) do
				omit_tags[tag .. "/" .. subtag] = true
			end
			local omit_paths = {}
			for _, loc in ipairs(tag_locations) do
				if omit_tags[loc.tag] then
					omit_paths[tostring(loc.path)] = true
				end
			end

			local seen, entries = {}, {}
			for _, loc in ipairs(tag_locations) do
				local path = tostring(loc.path)
				if not seen[path] and not omit_paths[path] then
					seen[path] = true
					entries[#entries + 1] = { text = loc.note:display_name(), filename = path }
				end
			end
			if vim.tbl_isempty(entries) and not opts.new_from_template then
				return vim.notify("No notes found with tag #" .. tag, vim.log.levels.WARN)
			end
			if opts.new_from_template then
				entries[#entries + 1] = { text = "+ New note from template", new_from_template = true }
			end
			vim.schedule(function()
				picker.pick(entries, {
					prompt_title = "#" .. tag,
					format_item = function(item)
						return item.text
					end,
					callback = function(item)
						if item.new_from_template then
							if opts.template then
								local title = api.input("Enter title or path (optional): ", { completion = "file" })
								if title == nil then
									return vim.notify("Aborted", vim.log.levels.WARN)
								end
								if title == "" then
									title = nil
								end
								local note = require("obsidian.note").create({ id = title, template = opts.template })
								note:write()
								return note:open({ sync = true })
							end
							return require("obsidian.actions").new_from_template(nil, nil, function(note)
								note:open({ sync = true })
							end)
						end
						api.open_note(item.filename)
					end,
				})
			end)
		end, { dir = api.resolve_workspace_dir() })
	end
end

return M
