require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

-- возврат курсор в состояние "палочки" при выходе
autocmd("VimLeave", {
  callback = function()
    vim.opt.guicursor = "a:ver25"
  end,
})
