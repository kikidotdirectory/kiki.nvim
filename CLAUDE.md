# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim config (`~/.config/nvim`) built on the MiniMax layout: `mini.nvim` supplies most functionality, plugins are managed by Neovim's built-in `vim.pack`. Requires Neovim 0.12+. There is no build, test, or lint suite — verification means starting Neovim.

## Failures are silent — verify deliberately

`Config.now` / `Config.later` / `Config.now_if_args` wrap their callback in `mini.misc.safely()`. A block that throws becomes a notification, not a startup error. **"Neovim started fine" is not evidence a change works.**

```sh
# Sources init.lua + plugin/*.lua and the `now`/`now_if_args` tiers
nvim --headless "+lua print('ok')" +qa

# Also exercises `later()` blocks (deferred via vim.schedule)
nvim --headless -c 'lua vim.defer_fn(function() vim.cmd("qa") end, 500)'
```

Inside a running instance, swallowed errors surface via `:messages` and `<Leader>eN` (MiniNotify history). `:checkhealth` covers LSP/treesitter wiring.

## Load order and the `_G.Config` contract

`init.lua` runs first and defines the global `Config` table — the loading helpers above plus `Config.new_autocmd` (all autocommands go through the `custom-config` augroup) and `Config.on_packchanged`. Neovim then sources `plugin/` alphabetically: `10_options.lua` → `20_keymaps.lua` → `30_mini.lua` → `40_plugins.lua`. Anything defined in an earlier file is available to later ones.

That ordering is load-bearing in one place: `20_keymaps.lua` populates `Config.leader_group_clues`, which `30_mini.lua` passes to `mini.clue`. A new `<Leader>` prefix therefore needs two edits in `20_keymaps.lua` — the mappings themselves, plus a group entry in the `leader_group_clues` table — or the clue window shows no description for it.

## Where things are wired

- **Plugins** — `plugin/40_plugins.lua`, grouped Core / Functional / Aesthetic, each added with `vim.pack.add()` inside `now_if_args` (needed at startup when opening a file) or `later` (deferred until idle). This file is the authority on what's active.
- **`nvim-pack-lock.json`** — written by Neovim, never hand-edited. Update plugins with `:lua vim.pack.update()` then `:write` to confirm. It currently retains ~10 entries for plugins no longer referenced anywhere in the config (colorschemes, `greggh/claude-code.nvim`, `json-nvim`, `nvim-fx`, `token`, `ts-error-translator`, …); do not treat it as an inventory.
- **Language servers** — two parts: the name must appear in `vim.lsp.enable({...})` in `40_plugins.lua`, and `after/lsp/<name>.lua` may return an override table (see `:h vim.lsp.config`). Several enabled servers (`vtsls`, `svelte`, `cssls`, `css_variables`, `jsonls`, `sourcekit`) have no override file and run on nvim-lspconfig defaults.
- **Formatting** — conform's `formatters_by_ft` in `40_plugins.lua` maps filetype → CLI, with `lsp_format = "fallback"`. Each CLI must be installed separately; `mason.nvim` is set up for that. Invoked via `<Leader>lf`.
- **Tree-sitter** — the `languages` list in `40_plugins.lua` drives both parser installation and the `FileType` autocommand calling `vim.treesitter.start`. Add a language in that one list.
- **Filetype behavior** — `after/ftplugin/<ft>.lua`, buffer-local only (`vim.bo`, `setlocal`, `vim.b.miniXxx_config`).
- **Snippets** — `snippets/global.json` loads everywhere; `after/snippets/<lang>.json` is language-scoped via `gen_loader.from_lang()`. Vento is the exception: its treesitter language resolves to `html`, so `after/ftplugin/vento.lua` loads its file explicitly.

## Editing conventions

Indentation is bimodal. Files formatted by stylua (defaults, no `.stylua.toml`) use **tabs**. Hand-aligned regions — most of `10_options.lua` and the Leader mapping tables in `20_keymaps.lua` — sit inside `-- stylua: ignore start` / `end` fences and use **2-space alignment with columns aligned by hand**. Match whichever regime you are editing in, and preserve column alignment inside the fences.

Comments in this config are documentation aimed at a reader inside Neovim: `:h helptag` references and worked mapping examples. New configuration should carry the same kind of comment.

## Gotchas

`.claude/worktrees/` contains complete copies of this config. Exclude it from `grep`/`find` sweeps or every result appears three times.
