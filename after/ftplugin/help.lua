vim.api.nvim_create_autocmd("BufWritePost", {
  buffer = 0,
  callback = function()
    vim.cmd("helptags " .. vim.fn.expand("%:p:h:h"))
  end,
})
