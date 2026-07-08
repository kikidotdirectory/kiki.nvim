-- Register Vento snippets for this buffer. `gen_loader.from_lang()` keys off the
-- treesitter language at the cursor (usually `html` in Vento files), so it never
-- picks up `snippets/vento.json`. Load it explicitly with `from_file` instead;
-- buffer-local snippets are appended to the global array.
local snippets = require("mini.snippets")
vim.b.minisnippets_config = {
	snippets = {
		snippets.gen_loader.from_file(vim.fn.stdpath("config") .. "/after/snippets/vento.json"),
	},
}
