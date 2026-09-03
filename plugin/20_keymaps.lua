-- ┌─────────────────┐
-- │ Custom mappings │
-- └─────────────────┘
--
-- This file contains definitions of custom general and Leader mappings.

-- General mappings ===========================================================

local nmap = function(lhs, rhs, desc)
	-- See `:h vim.keymap.set()`
	vim.keymap.set("n", lhs, rhs, { desc = desc })
end

nmap("<Esc>", "<cmd>nohlsearch<CR>")

-- Move between tabpages. Normal mode only, so that `<C-Left>`/`<C-Right>` keep
-- their built-in word-motion behavior in Insert mode.
nmap("<C-Left>", "<Cmd>tabprevious<CR>", "Previous tab")
nmap("<C-Right>", "<Cmd>tabnext<CR>", "Next tab")

vim.keymap.set({ "n", "x" }, "<C-,>", "<Cmd>ClaudeCodeFocus<CR>", { desc = "Claude Code (Ctrl+,)" })
vim.keymap.set({ "n", "x" }, "<C-.>", "<Cmd>ClaudeCodeOpen<CR>", { desc = "Switch to Claude Code (Ctrl+.)" })
-- terminal hide/switch-back are mapped in plugin/40_plugins.lua

local claudemap = function(modes, suffix, rhs, desc)
	vim.keymap.set(modes, "<C-s>" .. suffix, rhs, { desc = desc })
end

claudemap("v", "s", "<Cmd>ClaudeCodeSend<CR>", "Send selection to Claude")
claudemap("n", "w", "<Cmd>ClaudeCodeDiffAccept<CR>", "Accept Claude diff")
claudemap("n", "q", "<Cmd>ClaudeCodeDiffDeny<CR>", "Deny Claude diff")
claudemap("n", "a", "<Cmd>ClaudeCodeAdd %<CR>", "Add current buffer")
claudemap("n", "m", "<Cmd>ClaudeCodeSelectModel<CR>", "Select model")
claudemap("n", "v", "<Cmd>ClaudeCodeShow<CR>", "Show Claude Code (no focus)")

-- stylua: ignore start
-- Leader mappings ============================================================
_G.Config.leader_group_clues = {
  { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
  { mode = 'n', keys = '<Leader>e', desc = '+Explore/Edit' },
  { mode = 'n', keys = '<Leader>en',desc = '+Neovim' },
  { mode = 'n', keys = '<Leader>f', desc = '+Find' },
  { mode = 'n', keys = '<Leader>g', desc = '+Git' },
  { mode = 'n', keys = '<Leader>l', desc = '+Language' },
  { mode = 'n', keys = '<Leader>m', desc = '+Map' },
  { mode = 'n', keys = '<Leader>o', desc = '+Other' },
  { mode = 'n', keys = '<Leader>s', desc = '+Session' },
  { mode = 'n', keys = '<Leader>t', desc = '+Tab' },
  { mode = 'n', keys = '<Leader>v', desc = '+Visits' },

  { mode = 'x', keys = '<Leader>g', desc = '+Git' },
  { mode = 'x', keys = '<Leader>l', desc = '+Language' },
}

-- Helpers for a more concise `<Leader>` mappings.
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })
end
local xmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('x', '<Leader>' .. suffix, rhs, { desc = desc })
end

-- Buffer
local new_scratch_buffer = function()
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end

nmap_leader('ba', '<Cmd>b#<CR>',                                 'Alternate')
nmap_leader('bd', '<Cmd>lua MiniBufremove.delete()<CR>',         'Delete')
nmap_leader('bD', '<Cmd>lua MiniBufremove.delete(0, true)<CR>',  'Delete!')
nmap_leader('bs', new_scratch_buffer,                            'Scratch')
nmap_leader('bw', '<Cmd>lua MiniBufremove.wipeout()<CR>',        'Wipeout')
nmap_leader('bW', '<Cmd>lua MiniBufremove.wipeout(0, true)<CR>', 'Wipeout!')

-- e is for 'Explore' and 'Edit'. Common usage:
local edit_plugin_file = function(filename)
  return string.format('<Cmd>edit %s/plugin/%s<CR>', vim.fn.stdpath('config'), filename)
end
local explore_at_file = '<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>'
local explore_quickfix = function()
  for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.fn.getwininfo(win_id)[1].quickfix == 1 then return vim.cmd('cclose') end
  end
  vim.cmd('copen')
end

nmap_leader('ed', '<Cmd>lua MiniFiles.open()<CR>',          'Directory')
nmap_leader('ef', explore_at_file,                          'File directory')
nmap_leader('eg', '<Cmd>lua Snacks.lazygit.open()<CR>',     'Lazygit')
nmap_leader('eni', '<Cmd>edit $MYVIMRC<CR>',                'init.lua')
nmap_leader('enk', edit_plugin_file('20_keymaps.lua'),      'Keymaps config')
nmap_leader('enm', edit_plugin_file('30_mini.lua'),         'MINI config')
nmap_leader('eN', '<Cmd>lua MiniNotify.show_history()<CR>', 'Notifications')
nmap_leader('eno', edit_plugin_file('10_options.lua'),      'Options config')
nmap_leader('enp', edit_plugin_file('40_plugins.lua'),      'Plugins config')
nmap_leader('eq', explore_quickfix,                         'Quickfix')

-- f is for 'Fuzzy Find'. Common usage:
local pick_added_hunks_buf = '<Cmd>Pick git_hunks path="%" scope="staged"<CR>'
local pick_workspace_symbols_live = '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>'
local function pick_workspace_todos()
	local pattern = [[\b(TODO|Todo|todo):]]

  MiniPick.start({
    source = {
      name = 'Todos workspace',
      items = function()
        MiniPick.set_picker_items_from_cli(
          { 'rg', '--vimgrep', '--smart-case', pattern },
          {
            postprocess = function(lines)
              local items = {}
              for _, line in ipairs(lines) do
                -- rg --vimgrep output: path:lnum:col:full_line_text
                local path, lnum, col, text = line:match('^(.-):(%d+):(%d+):(.*)$')
                if path then
                  local trimmed = text:gsub('^.-[Tt][Oo][Dd][Oo]:%s*', '')
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
          }
        )
      end,
    },
  })
end

nmap_leader('f/', '<Cmd>Pick history scope="/"<CR>',           '"/" history')
nmap_leader('f:', '<Cmd>Pick history scope=":"<CR>',           '":" history')
nmap_leader('fa', '<Cmd>Pick git_hunks scope="staged"<CR>',    'Added hunks (all)')
nmap_leader('fA', pick_added_hunks_buf,                        'Added hunks (buf)')
nmap_leader('fb', '<Cmd>Pick buffers<CR>',                     'Buffers')
nmap_leader('fc', '<Cmd>Pick git_commits<CR>',                 'Commits (all)')
nmap_leader('fC', '<Cmd>Pick git_commits path="%"<CR>',        'Commits (buf)')
nmap_leader('fd', '<Cmd>Pick diagnostic scope="all"<CR>',      'Diagnostic workspace')
nmap_leader('fD', '<Cmd>Pick diagnostic scope="current"<CR>',  'Diagnostic buffer')
nmap_leader('ff', '<Cmd>Pick files<CR>',                       'Files')
nmap_leader('fg', '<Cmd>Pick grep_live<CR>',                   'Grep live')
nmap_leader('fG', '<Cmd>Pick grep pattern="<cword>"<CR>',      'Grep current word')
nmap_leader('fh', '<Cmd>Pick help<CR>',                        'Help tags')
nmap_leader('fH', '<Cmd>Pick hl_groups<CR>',                   'Highlight groups')
nmap_leader('fl', '<Cmd>Pick buf_lines scope="all"<CR>',       'Lines (all)')
nmap_leader('fL', '<Cmd>Pick buf_lines scope="current"<CR>',   'Lines (buf)')
nmap_leader('fm', '<Cmd>Pick git_hunks<CR>',                   'Modified hunks (all)')
nmap_leader('fM', '<Cmd>Pick git_hunks path="%"<CR>',          'Modified hunks (buf)')
nmap_leader('fo', '<Cmd>Pick oldfiles current_dir=true<CR>',   'Oldfiles (workspace)')
nmap_leader('fO', '<Cmd>Pick oldfiles<CR>',                    'Oldfiles (all)')
nmap_leader('fr', '<Cmd>Pick resume<CR>',                      'Resume')
nmap_leader('fR', '<Cmd>Pick lsp scope="references"<CR>',      'References (LSP)')
nmap_leader('fs', '<Cmd>Pick lsp scope="document_symbol"<CR>', 'Symbols document')
nmap_leader('fS', pick_workspace_symbols_live,                 'Symbols workspace (live)')
nmap_leader('ft', pick_workspace_todos,                        'Todos workspace')
nmap_leader('fv', '<Cmd>Pick visit_paths cwd=""<CR>',          'Visit paths (all)')
nmap_leader('fV', '<Cmd>Pick visit_paths<CR>',                 'Visit paths (cwd)')

-- fo is for 'Obsidian'. Notes-by-tag pickers. Add a new tag with one line:
--   nmap_leader('foX', make_pick_tag('x'), 'Notes tagged #x')
-- Pass `new_from_template = true` to append a trailing entry that creates a
-- new note from a template instead of opening an existing one.
-- Pass `template = 'name.md'` (a filename inside the templates dir) to skip
-- the templates picker and use that template directly.
-- Pass `omit_subtags = { 'done', 'archived' }` to exclude notes also tagged
-- with any of these subtags (e.g. `#project/done`). Defaults to none.
local make_pick_tag = function(tag, opts)
  opts = opts or {}
  local omit_subtags = opts.omit_subtags or {}
  return function()
    local search = require 'obsidian.search'
    local picker = require('obsidian.picker').get()
    local api = require 'obsidian.api'

    local handled = false
    search.find_tags_async(tag, function(tag_locations)
      -- NOTE: obsidian.nvim's find_tags_async can invoke this callback twice
      -- when the search finds no matches (missing `return` after an early
      -- `callback {}` on nonzero exit code). Guard against opening the
      -- picker twice, which force-closes the first one immediately.
      if handled then return end
      handled = true

      local omit_tags = {}
      for _, subtag in ipairs(omit_subtags) do
        omit_tags[tag .. '/' .. subtag] = true
      end
      local omit_paths = {}
      for _, loc in ipairs(tag_locations) do
        if omit_tags[loc.tag] then omit_paths[tostring(loc.path)] = true end
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
        return vim.notify('No notes found with tag #' .. tag, vim.log.levels.WARN)
      end
      if opts.new_from_template then
        entries[#entries + 1] = { text = '+ New note from template', new_from_template = true }
      end
      vim.schedule(function()
        picker.pick(entries, {
          prompt_title = '#' .. tag,
          format_item = function(item) return item.text end,
          callback = function(item)
            if item.new_from_template then
              if opts.template then
                local title = api.input('Enter title or path (optional): ', { completion = 'file' })
                if title == nil then return vim.notify('Aborted', vim.log.levels.WARN) end
                if title == '' then title = nil end
                local note = require('obsidian.note').create { id = title, template = opts.template }
                note:write()
                return note:open { sync = true }
              end
              return require('obsidian.actions').new_from_template(nil, nil, function(note) note:open { sync = true } end)
            end
            api.open_note(item.filename)
          end,
        })
      end)
    end, { dir = api.resolve_workspace_dir() })
  end
end

-- todo: separate non-picker obsidian related commands
-- todo: migrate picker to its own file
nmap_leader('oi', make_pick_tag('project/idea', { new_from_template = true, template = "project.md" }), 'Notes tagged #project')
nmap_leader('op', make_pick_tag('project', { new_from_template = true, template = "project.md", omit_subtags = {"done", "idea", "archived"} }), 'Notes tagged #project')
nmap_leader('on', '<Cmd>Obsidian new<CR>',    'New note')

-- g is for 'Git'. Common usage:
-- - `<Leader>gs` - show information at cursor
-- - `<Leader>go` - toggle 'mini.diff' overlay to show in-buffer unstaged changes
-- - `<Leader>gd` - show unstaged changes as a patch in separate tabpage
-- - `<Leader>gL` - show Git log of current file
local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. ' --follow -- %'

nmap_leader('ga', '<Cmd>Git diff --cached<CR>',             'Added diff')
nmap_leader('gA', '<Cmd>Git diff --cached -- %<CR>',        'Added diff buffer')
nmap_leader('gc', '<Cmd>Git commit<CR>',                    'Commit')
nmap_leader('gC', '<Cmd>Git commit --amend<CR>',            'Commit amend')
nmap_leader('gd', '<Cmd>Git diff<CR>',                      'Diff')
nmap_leader('gD', '<Cmd>Git diff -- %<CR>',                 'Diff buffer')
nmap_leader('gl', '<Cmd>' .. git_log_cmd .. '<CR>',         'Log')
nmap_leader('gL', '<Cmd>' .. git_log_buf_cmd .. '<CR>',     'Log buffer')
nmap_leader('go', '<Cmd>lua MiniDiff.toggle_overlay()<CR>', 'Toggle overlay')
nmap_leader('gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>',  'Show at cursor')

xmap_leader('gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>', 'Show at selection')

-- l is for 'Language'. Common usage:
-- NOTE: most LSP mappings represent a more structured way of replacing built-in
-- LSP mappings (like `:h gra` and others). This is needed because `gr` is mapped
-- by an "replace" operator in 'mini.operators' (which is more commonly used).
local formatting_cmd = '<Cmd>lua require("conform").format({lsp_fallback=true})<CR>'

nmap_leader('la', '<Cmd>lua vim.lsp.buf.code_action()<CR>',     'Actions')
nmap_leader('ld', '<Cmd>lua vim.diagnostic.open_float()<CR>',   'Diagnostic popup')
nmap_leader('lf', formatting_cmd,                               'Format')
nmap_leader('li', '<Cmd>lua vim.lsp.buf.implementation()<CR>',  'Implementation')
nmap_leader('lh', '<Cmd>lua vim.lsp.buf.hover()<CR>',           'Hover')
nmap_leader('lr', '<Cmd>lua vim.lsp.buf.rename()<CR>',          'Rename')
nmap_leader('lR', '<Cmd>lua vim.lsp.buf.references()<CR>',      'References')
nmap_leader('ls', '<Cmd>lua vim.lsp.buf.definition()<CR>',      'Source definition')
nmap_leader('lt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', 'Type definition')

xmap_leader('lf', formatting_cmd, 'Format selection')

-- m is for 'Map'. Common usage:
-- - `<Leader>mt` - toggle map from 'mini.map' (closed by default)
-- - `<Leader>mf` - focus on the map for fast navigation
-- - `<Leader>ms` - change map's side (if it covers something underneath)
nmap_leader('mf', '<Cmd>lua MiniMap.toggle_focus()<CR>', 'Focus (toggle)')
nmap_leader('mr', '<Cmd>lua MiniMap.refresh()<CR>',      'Refresh')
nmap_leader('ms', '<Cmd>lua MiniMap.toggle_side()<CR>',  'Side (toggle)')
nmap_leader('mt', '<Cmd>lua MiniMap.toggle()<CR>',       'Toggle')

-- o is for 'Other'. Common usage:
-- - `<Leader>oz` - toggle between "zoomed" and regular view of current buffer
nmap_leader('or', '<Cmd>lua MiniMisc.resize_window()<CR>', 'Resize to default width')
nmap_leader('ot', '<Cmd>lua MiniTrailspace.trim()<CR>',    'Trim trailspace')
nmap_leader('oz', '<Cmd>lua MiniMisc.zoom()<CR>',          'Zoom toggle')

-- s is for 'Session'. Common usage:
-- - `<Leader>sn` - start new session
-- - `<Leader>sr` - read previously started session
-- - `<Leader>sd` - delete previously started session
local session_new = 'MiniSessions.write(vim.fn.input("Session name: "))'

nmap_leader('sd', '<Cmd>lua MiniSessions.select("delete")<CR>', 'Delete')
nmap_leader('sn', '<Cmd>lua ' .. session_new .. '<CR>',         'New')
nmap_leader('sr', '<Cmd>lua MiniSessions.select("read")<CR>',   'Read')
nmap_leader('sw', '<Cmd>lua MiniSessions.write()<CR>',          'Write current')

-- t is for 'Tab'. Common usage:
-- - `<Leader>tn` - open a new tabpage
-- - `<Leader>th` / `<Leader>tl` - go to previous/next tabpage (same as `<C-Left>`/`<C-Right>`)
-- - `<Leader>t<` / `<Leader>t>` - move current tabpage left/right
nmap_leader('t<', '<Cmd>-tabmove<CR>',    'Move left')
nmap_leader('t>', '<Cmd>+tabmove<CR>',    'Move right')
nmap_leader('tc', '<Cmd>tabclose<CR>',    'Close')
nmap_leader('tf', '<Cmd>tabfirst<CR>',    'First')
nmap_leader('th', '<Cmd>tabprevious<CR>', 'Previous')
nmap_leader('tl', '<Cmd>tabnext<CR>',     'Next')
nmap_leader('tL', '<Cmd>tablast<CR>',     'Last')
nmap_leader('tn', '<Cmd>tabnew<CR>',      'New')
nmap_leader('to', '<Cmd>tabonly<CR>',     'Only (close others)')

-- v is for 'Visits'. Common usage:
-- - `<Leader>vv` - add    "core" label to current file.
-- - `<Leader>vV` - remove "core" label to current file.
-- - `<Leader>vc` - pick among all files with "core" label.
local make_pick_core = function(cwd, desc)
  return function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    local local_opts = { cwd = cwd, filter = 'core', sort = sort_latest }
    MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
  end
end

nmap_leader('vc', make_pick_core('',  'Core visits (all)'),       'Core visits (all)')
nmap_leader('vC', make_pick_core(nil, 'Core visits (cwd)'),       'Core visits (cwd)')
nmap_leader('vv', '<Cmd>lua MiniVisits.add_label("core")<CR>',    'Add "core" label')
nmap_leader('vV', '<Cmd>lua MiniVisits.remove_label("core")<CR>', 'Remove "core" label')
nmap_leader('vl', '<Cmd>lua MiniVisits.add_label()<CR>',          'Add label')
nmap_leader('vL', '<Cmd>lua MiniVisits.remove_label()<CR>',       'Remove label')
-- stylua: ignore end
