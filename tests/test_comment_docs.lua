local mini_test = require("mini.test")
local new_set = mini_test.new_set
local eq = mini_test.expect.equality
local docs = require("comment_docs")

local T = new_set()

T["no match mid-word"] = function()
	eq(docs.docs_trigger("-- see roadocs/foo"), nil)
end

T["matches, captures prefix"] = function()
	local _, prefix = docs.docs_trigger("-- see docs/guide")
	eq(prefix, "docs/guide")
end

return T
