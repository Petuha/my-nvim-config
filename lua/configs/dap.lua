-- Настройка внешнего вида значков
local signs = {
  DapBreakpoint = { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" },
  DapBreakpointCondition = { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" },
  DapLogPoint = { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" },
  DapStopped = { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "DapStoppedLine" },
  DapBreakpointRejected = { text = "", texthl = "DapBreakpointRejected", linehl = "", numhl = "" },
}

for name, sign in pairs(signs) do
  vim.fn.sign_define(name, sign)
end

-- Настройка цветов (Highlight groups)
vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75" }) -- Красный кружок
vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#98c379" })
vim.api.nvim_set_hl(0, "DapStopped", { fg = "#e5c07b" }) -- Желтая стрелка
vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#3e4452" }) -- Подсветка строки, где стоит дебаггер

