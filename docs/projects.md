---
id: projects
aliases: []
tags: []
---

Inspired by [Coping strategies for the serial project hoarder](https://simonwillison.net/2022/Nov/26/productivity/)

Documentation & logging for each project lives in its own /docs/ folder.

I forked [filepaths_ls](https://github.com/kikidotdirectory/filepaths_ls.nvim) to add a small modification to build paths from the root directory by default.[^1] The goal is for comments to link directly to it and (in neovim), to be able to jump to those paths with `gf`.

For ergonomics, `plugin/40_plugins.lua` defines a docs picker which lists all the files within the directory.
more work on this tbd

---

[^1]: The original maintainer seemed relatively opposed to the notion but I think it's relatively straightforward to support both `cwd`-based, buffer-relative, and root-relative paths. I'll see if my opinion changes when I use it more.
