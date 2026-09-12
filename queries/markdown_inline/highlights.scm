; From MDeiml/tree-sitter-markdown, with one change: shortcut links whose
; text is one of the obsidian.nvim custom checkbox states ("~", "!", ">")
; are exempted from bracket concealment, since tree-sitter-markdown's
; task_list_marker regex only recognizes "[ ]"/"[x]" (see grammar.js), so
; anything else -- "- [~]", "- [!]", "- [>]" -- parses as a shortcut_link
; and would otherwise have its brackets hidden by the rule below,
; independent of `ui.checkboxes` in the obsidian.nvim setup (@40_plugins.lua).
(code_span) @markup.raw @nospell

(emphasis) @markup.italic

(strong_emphasis) @markup.strong

(strikethrough) @markup.strikethrough

(shortcut_link
  (link_text) @nospell)

; Conceal backslash in backslash escapes
((backslash_escape) @conceal
  (#offset! @conceal 0 0 0 -1)
  (#set! conceal ""))

; Conceal backslash in hard line breaks
((hard_line_break
  "\\" @conceal)
  (#set! conceal ""))

; Conceal codeblock and text style markers
([
  (code_span_delimiter)
  (emphasis_delimiter)
] @conceal
  (#set! conceal ""))

; Conceal inline links
(inline_link
  [
    "["
    "]"
    "("
    (link_destination)
    ")"
  ] @markup.link
  (#set! conceal ""))

[
  (link_label)
  (link_text)
  (link_title)
  (image_description)
] @markup.link.label

((inline_link
  (link_destination) @_url) @_label
  (#set! @_label url @_url))

((image
  (link_destination) @_url) @_label
  (#set! @_label url @_url))

; Conceal image links
(image
  [
    "!"
    "["
    "]"
    "("
    (link_destination)
    ")"
  ] @markup.link
  (#set! conceal ""))

; Conceal full reference links
(full_reference_link
  [
    "["
    "]"
    (link_label)
  ] @markup.link
  (#set! conceal ""))

; Conceal collapsed reference links
(collapsed_reference_link
  [
    "["
    "]"
  ] @markup.link
  (#set! conceal ""))

; Conceal shortcut links, except obsidian.nvim's custom checkbox states.
; Brackets are matched as two patterns (not a "[" "]" choice) because a
; choice alternator must appear at the same tree position as it's written
; in the pattern -- putting (link_text) first would only ever bind "]"
; (the sibling *after* it), silently skipping the opening "[".
;
; `conceal` is set on the "[" / "]" capture specifically, not bare
; `(#set! conceal "")`: an unscoped #set! stores match-level metadata, and
; highlighter.lua reads `metadata.conceal or metadata[capture].conceal` --
; match-level wins and gets applied to *every* capture in the match,
; including @_text. That was hiding the link_text along with the brackets,
; so footnote markers like [^1] and Obsidian inline footnotes (^[...])
; rendered as nothing instead of just losing their brackets.
(shortcut_link
  "[" @markup.link
  .
  (link_text) @_text
  (#not-any-of? @_text "~" "!" ">")
  (#set! @markup.link conceal ""))

(shortcut_link
  (link_text) @_text
  .
  "]" @markup.link
  (#not-any-of? @_text "~" "!" ">")
  (#set! @markup.link conceal ""))

; For the exempted checkbox states, color the brackets the same as the
; state character instead of leaving them with no highlight.
(shortcut_link
  "[" @markup.link.label
  .
  (link_text) @_text
  (#any-of? @_text "~" "!" ">"))

(shortcut_link
  (link_text) @_text
  .
  "]" @markup.link.label
  (#any-of? @_text "~" "!" ">"))

[
  (link_destination)
  (uri_autolink)
  (email_autolink)
] @markup.link.url @nospell

((uri_autolink) @_url
  (#offset! @_url 0 1 0 -1)
  (#set! @_url url @_url))

(entity_reference) @nospell

; Replace common HTML entities.
((entity_reference) @character.special
  (#eq? @character.special "&nbsp;")
  (#set! conceal " "))

((entity_reference) @character.special
  (#eq? @character.special "&lt;")
  (#set! conceal "<"))

((entity_reference) @character.special
  (#eq? @character.special "&gt;")
  (#set! conceal ">"))

((entity_reference) @character.special
  (#eq? @character.special "&amp;")
  (#set! conceal "&"))

((entity_reference) @character.special
  (#eq? @character.special "&quot;")
  (#set! conceal "\""))

((entity_reference) @character.special
  (#any-of? @character.special "&ensp;" "&emsp;")
  (#set! conceal " "))
