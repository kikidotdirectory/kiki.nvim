Root cause: mini.indentscope is set up with require("mini.indentscope").setup() (plugin/30_mini.lua:549) using its defaults, which bind the literal two-key sequences ai/ii in visual/operator-pending mode to object_scope_with_border/object_scope (indentation-based textobjects). I confirmed this directly:

xmap  ai  →  <Cmd>lua MiniIndentscope.textobject(true)<CR>   ("Object scope with border")

mini.ai's own mappings are just the single keys a/i (they read the id character afterward via getchar). When you type a then i, Neovim has two candidate mappings sharing that prefix — the complete ai mapping from indentscope, and the single-key a mapping from mini.ai awaiting a further id char. Vim's key resolution prefers the longer, already-complete match, so ai/ii get swallowed by indentscope before mini.ai ever gets to treat i as your custom conditional id. That's true for any custom textobject id you pick as "i" — it has nothing to do with TypeScript or the treesitter query specifically.

I verified the treesitter query itself is correct — ecma/textobjects.scm (inherited by both javascript and typescript) does define if_statement as @conditional.outer/@conditional.inner properly, and calling MiniAi.find_textobject('a', 'i', {...}) directly (bypassing keymaps) returns nothing because the id conflict happens purely at the key-dispatch layer, not in the spec logic. The "expression"-like selection you saw is mini.indentscope's indentation-scope selection, not a treesitter match at all — it just happened to produce a narrow region in your test case, which read as "expression."

Fix: either give the conditional textobject a different id that doesn't collide (e.g. n is reserved for "next" search, but something like y or ?... really any letter not already claimed), or remap mini.indentscope's mappings off ai/ii in its setup() call, e.g.:

```
require("mini.indentscope").setup({
  mappings = {
    object_scope = "ii",           -- keep, or change
    object_scope_with_border = "ai",
  },
})
```

Since you clearly want i reserved for "conditional" as a mnemonic to match f/c/l, the cleaner fix is remapping indentscope's scope textobjects to different keys (they don't have as strong a mnemonic claim on i as your conditional textobject does) rather than picking an awkward id for conditionals.
