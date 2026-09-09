local M = {}

-- todo: way to order todos in list? maybe as random file?
function M.pick_workspace_todos()
	local pattern = [[\b(TODO|Todo|todo):]]

	MiniPick.start({
		source = {
			name = "Todos workspace",
			items = function()
				MiniPick.set_picker_items_from_cli({ "rg", "--vimgrep", "--smart-case", pattern }, {
					postprocess = function(lines)
						local items = {}
						for _, line in ipairs(lines) do
							-- rg --vimgrep output: path:lnum:col:full_line_text
							local path, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
							if path then
								local trimmed = text:gsub("^.-[Tt][Oo][Dd][Oo]:%s*", "")
								table.insert(items, {
									path = path,
									lnum = tonumber(lnum),
									col = tonumber(col),
									text = trimmed,
								})
							end
						end
						return items
					end,
				})
			end,
		},
	})
end

return M
