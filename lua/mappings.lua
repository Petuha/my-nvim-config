require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
-- map("i", "jk", "<ESC>")

map("i", "<C-H>", "<C-w>", { desc = "Delete previous word with Ctrl + Backspace" })
map("n", "<C-H>", "a<C-w><ESC>", { desc = "Delete previous word with Ctrl + Backspace" })

map("i", "<C-Del>", "<C-o>dw", { desc = "Delete next word with Ctrl + Delete" })
map("n", "<C-Del>", "dw", { desc = "Delete next word with Ctrl + Delete" })

map("n", "<C-c>", "a", { desc = "Enter INSERT mode from NORMAL" })

map({ "n", "i", "v" }, "<C-b>", "<cmd> CMakeBuild <cr>")
map({ "n", "i", "v" }, "<C-r>", "<cmd> CMakeRun <cr>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
