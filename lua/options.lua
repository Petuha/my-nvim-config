require "nvchad.options"

vim.opt.guicursor:append "t:ver25-blinkon0"

local opt = vim.opt

opt.wrap = true
opt.linebreak = true
vim.opt.virtualedit = "onemore"

-- экранирование спецсимволов для корректной работы langmap
local function escape(str)
  local escape_chars = [[;,."'\]]
  return str:gsub("([" .. escape_chars:gsub("%W", "%%%1") .. "])", "\\%1")
end

local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm,./~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?]]
local ru = [[ёйцукенгшщзхъфывапролджэячсмитьбю.ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,]]

-- установка langmap
vim.opt.langmap = vim.fn.join({
  escape(ru) .. ';' .. escape(en),
}, ',')
