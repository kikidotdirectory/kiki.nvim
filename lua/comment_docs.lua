-- when typing in comments, typing `docs/` will create a completion of the project directory's files in docs.
--
-- depends on Mini.Misc setting project root
-- see :h MiniMisc.setup_auto_root()

-- triggered insertCharPre
-- if the current string is in a `comment_content` node AND if the ending of the line is a docs/ path

local M = {}

local function docs_trigger(line, col)
	local s, _, match = line:sub(1, col):find("%f[%a](docs/[%w_%.%-/]*)$")
	if not s then
		return nil
	end
	return s, match
end

local function notify(notification)
	vim.notify(tostring(notification))
end

function M.complete()
	-- print(in_comment())

	-- local line = vim.api.nvim_get_current_line()
	-- local col = vim.api.nvim_win_get_cursor(0)[2]
	-- local result = docs_trigger(line, col)
	-- print(result)
end

M.docs_trigger = docs_trigger

return M
