require "nvchad.mappings"

local map = vim.keymap.set


-- base

map("n", ";", ":", { desc = "CMD enter command mod" })
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>", { desc = "Save file" })
map({ "n", "i", "v" }, "<C-e>", "<cmd> NvimTreeToggle <cr>", { desc = "Toggle file explorer" })

map("n", "<C-c>", "a", { desc = "Enter INSERT mod from NORMAL" })
-- map("v", "<C-c>", "<ESC>a", { desc = "Enter INSERT mod from VISUAL" })

map({ "n", "i", "v" }, "<C-f>", "<ESC>:/", { desc = "Find" })
map("c", "<C-f>", "<C-c>", { desc = "Find cancel" })

-- delete words

map("i", "<C-H>", "<C-w>", { desc = "Delete previous word with Ctrl + Backspace" })
map("n", "<C-H>", "a<C-w><ESC>", { desc = "Delete previous word with Ctrl + Backspace" })

map("i", "<C-Del>", "<C-o>dw", { desc = "Delete next word with Ctrl + Delete" })
map("n", "<C-Del>", "dw", { desc = "Delete next word with Ctrl + Delete" })


-- undo / redo

map({ "n", "i", "v" }, "<C-z>", "<cmd> undo <cr>", { desc = "Undo" })
map({ "n", "i", "v" }, "<C-y>", "<cmd> redo <cr>", { desc = "Redo" })


-- VISUAL mod

map("i", "<C-v>", "<ESC>lv", { desc = "Enter VISUAL mod" }) -- 'l' - for 1 tile to right
map("n", "<C-v>", "v", { desc = "Enter VISUAL mod" })
map("v", "<C-v>", "<ESC>", { desc = "Exit VISUAL mod" })
map({ "n", "v" }, "<M-v>", "<C-v>", { desc = "Enter V-BLOCK mod" })

map("v", "<BS>", "d", { desc = "Delete selection with Backspace" })

map("n", "<C-a>", "ggVG", { desc = "Select all" })
map({ "i", "v" }, "<C-a>", "<ESC>ggVG", { desc = "Select all" })

map("v", "c", '"+y', { desc = "Copy on c" })
map("v", "x", '"+x', { desc = "Cut on x" })


-- buffers

map({ "n", "i", "v" }, "<C-PageDown>", function()
  require("nvchad.tabufline").next()
end, { desc = "Prev buffer" })
map({ "n", "i", "v" }, "<C-PageUp>", function()
  require("nvchad.tabufline").prev()
end,{ desc = "Next buffer" })

map({ "n", "i", "v" }, "<C-n>", "<cmd> enew <cr>", { desc = "New buffer" })
map({ "n", "i", "v" }, "<C-x>", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Close buffer" })


-- CMake

map({ "n", "i", "v" }, "<C-b>", "<cmd> CMakeBuild <cr>", { desc = "Build with cmake" })
map({ "n", "i", "v" }, "<C-r>", "<cmd> CMakeRun <cr>", { desc = "Build with cmake" })


-- clang-format

map("v", "f", function()
  require("conform").format({
    lsp_fallback = false,
    async = false,
    timeout_ms = 500,
  }, function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  end)
end, { desc = "Format selection" })


-- debugger

map("n", "<F5>", function() require("dap").continue() end, { desc = "DAP Continue" })
map("n", "<F6>", function() require("dap").terminate() end, { desc = "DAP Terminate" })
map("n", "<F10>", function() require("dap").step_over() end, { desc = "DAP Step Over" })
map("n", "<F9>", function() require("dap").step_into() end, { desc = "DAP Step Into" })
map("n", "<F12>", function() require("dap").step_out() end, { desc = "DAP Step Out" })

map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
map("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = "DAP Conditional Breakpoint" })

map("n", "<leader>du", function() require("dapui").toggle() end, { desc = "DAP Toggle UI" })
-- map("n", "<leader>dr", function() require("dap").repl.open() end, { desc = "DAP Open REPL" })
