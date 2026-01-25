require "nvchad.mappings"

local map = vim.keymap.set

local function press(keys)
    local termcodes = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(termcodes, "n", true)
end

local function is_first_char()
  return vim.fn.col('.') == 1
end

local function is_last_char()
  return vim.fn.col('.') >= vim.fn.col('$')
end

local function from_insert_to_normal()
  if is_first_char() then
    press("<ESC>")
  else
    press("<ESC>l")
  end
end


-- base

map("n", ";", ":", { desc = "CMD enter command mod" })
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>", { desc = "Save file" })
map({ "n", "i", "v" }, "<C-e>", "<ESC><cmd> NvimTreeToggle <cr>", { desc = "File explorer toggle" })


map("n", "<C-x>", "i", { desc = "ChangeMod To INSERT" })
map("n", "a", "i", { desc = "ChangeMod To INSERT" })
map("i", "<C-x>", function()
  from_insert_to_normal()
end, { desc = "ChangeMod To NORMAL" })

map("v", "<C-x>", "<ESC>", { desc = "ChangeMod To NORMAL" })
map({ "n", "i", "v" }, "<C-c>", "")

map({ "n", "v" }, "<C-f>", "<ESC>/", { desc = "Find" })
map("i", "<C-f>", function()
  from_insert_to_normal()
  press("<ESC>/")
end, { desc = "Find" })
map("c", "<C-f>", "<C-c>", { desc = "Find cancel" })

map({ "n", "i", "v" }, "<C-g>", "<cmd>normal! za<cr>", { desc = "Fold toggle" })

map({ "n", "i", "v" }, "<C-t>", function()
  local oldfiles = vim.v.oldfiles
  local open_buffers = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      open_buffers[vim.api.nvim_buf_get_name(bufnr)] = true
    end
  end
  for _, file in ipairs(oldfiles) do
    if not open_buffers[file] and vim.fn.filereadable(file) == 1 then
      vim.cmd("edit " .. file)
      return
    end
  end
  print "No recently closed files found."
end, { desc = "Open last closed file" })


-- navigation

local function resolve_mod(keys)
  if vim.api.nvim_get_mode().mode == "i" then
    keys = "<C-o>" .. keys
  end
  return keys
end

map("n", "<Left>", function()
  local cur_line = vim.fn.line('.')
  if vim.fn.col('.') == 1 then
    if cur_line > 1 then
      local prev_line = cur_line - 1
      local prev_line_len = #vim.fn.getbufline(vim.api.nvim_get_current_buf(), prev_line)[1]
      vim.api.nvim_win_set_cursor(0, {prev_line, prev_line_len})
    end
  else
    vim.cmd("normal! h")
  end
end, { desc = "Move left" })

map({ "n", "i", "v" }, "<C-Left>", function()
  local start_line = vim.fn.line(".")
  local keys = resolve_mod("<C-Left>")
  press(keys)
  vim.schedule(function()
    local cur_line = vim.fn.line(".")
    if cur_line ~= start_line then
      local cur_line_len = #vim.fn.getbufline(vim.api.nvim_get_current_buf(), cur_line)[1]
      vim.api.nvim_win_set_cursor(0, {cur_line, cur_line_len})
    end
  end)
end, { desc = "Move word left" })

map({ "n", "i", "v" }, "<C-Right>", function()
  local last_char = is_last_char()
  local start_line = vim.fn.line(".")
  local keys = resolve_mod("<C-Right>")
  press(keys)
  if last_char then
    return
  end
  vim.schedule(function()
    local cur_line = vim.fn.line(".")
    if cur_line ~= start_line then
      local start_line_len = #vim.fn.getbufline(vim.api.nvim_get_current_buf(), start_line)[1]
      vim.api.nvim_win_set_cursor(0, {start_line, start_line_len})
    end
  end)
end, { desc = "Move word right" })

map("i", "<Up>", "<C-o>gk", { desc = "Move up" })
map({ "n", "v" }, "<Up>", "gk", { desc = "Move up" })
map("i", "<Down>", "<C-o>gj", { desc = "Move down" })
map({ "n", "v" }, "<Down>", "gj", { desc = "Move down" })

map("i", "<PageUp>", "<C-o><C-u>", { desc = "Move half page up" })
map("i", "<PageDown>", "<C-o><C-d>", { desc = "Move half page down" })
map({ "n", "v" }, "<PageUp>", "<C-u>", { desc = "Move half page up" })
map({ "n", "v" }, "<PageDown>", "<C-d>", { desc = "Move half page down" })
map({ "n", "i", "v" }, "<C-u>", "")
map({ "n", "i", "v" }, "<C-d>", "")

map({ "n", "i", "v" }, "<C-Up>", "<cmd>normal! <C-y><cr>", { desc = "Move screen up" })
map({ "n", "i", "v" }, "<C-Down>", "<cmd>normal! <C-e><cr>", { desc = "Move screen down" })

local function open_file_under_the_cursor()
  local file_path = vim.fn.expand("<cfile>")
  -- "^%a+://" - link like "http://..."
  if file_path:match("^%a+://") or file_path:match("^~") or file_path:match("^/") then
    vim.ui.open(file_path)
  else
    local current_dir = vim.fn.expand("%:p:h")
    local absolute_path = current_dir .. "/" .. file_path
    vim.ui.open(absolute_path)
  end
end
map("n", "<F4>", function()
  open_file_under_the_cursor()
end, { desc = "Open File under the cursor" })
map("i", "<F4>", function()
  from_insert_to_normal()
  open_file_under_the_cursor()
  press("i")
end, { desc = "Open File under the cursor" })


-- delete words

map("n", "<Del>", "")
map("n", "<C-Del>", "")
map("n", "<S-Del>", "")
map("n", "<C-S-Del>", "")

map("n", "D", "\"_D")
map({ "n", "v" }, "d", "\"_d")

map("i", "<C-w>", "")

map("i", "<C-H>", "<C-w>", { desc = "Delete previous word with Ctrl + Backspace" })
-- map("n", "<C-H>", "a<C-w><ESC>", { desc = "Delete previous word with Ctrl + Backspace" })

map("i", "<C-Del>", "<C-o>\"_dw", { desc = "Delete next word with Ctrl + Delete" })
-- map("n", "<C-Del>", "dw", { desc = "Delete next word with Ctrl + Delete" })


-- undo / redo

map({ "n", "i", "v" }, "<C-z>", "<cmd> undo <cr>", { desc = "Change Undo" })
map({ "n", "i", "v" }, "<C-y>", "<cmd> redo <cr>", { desc = "Change Redo" })


-- VISUAL mod

map("v", "<BS>", "\"_d", { desc = "VISUAL delete selection" })
map("v", "<Del>", "\"_d", { desc = "VISUAL delete selection" })
map("v", "d", "\"_d", { desc = "VISUAL delete selection" })

map({ "n", "i", "v" }, "<C-a>", "<ESC>ggVG", { desc = "VISUAL select all" })

map("v", "c", '"+ygv<Esc>', { desc = "VISUAL copy" })
map("v", "x", '"+x', { desc = "VISUAL cut" })
map("v", "p", '"_dP', { desc = "VISUAL paste" })
map("v", "P", '"_dP', { desc = "VISUAL paste" })

map("i", "<S-Up>", function()
  from_insert_to_normal()
  press("vgko<Left>o")
end, { desc = "VISUAL up from NORMAL" })
map("i", "<C-S-Up>", function()
  from_insert_to_normal()
  press("v<C-Up>o<Left>o")
end, { desc = "VISUAL up from NORMAL" })

map("i", "<S-Down>", function()
  from_insert_to_normal()
  press("vgj")
end, { desc = "VISUAL down from NORMAL" })
map("i", "<C-S-Down>", function()
  from_insert_to_normal()
  press("v<C-Down>")
end, { desc = "VISUAL down from NORMAL" })

map("i", "<S-Left>", function()
  press("<Left>")
  from_insert_to_normal()
  press("v")
end, { desc = "VISUAL left from NORMAL" })
map("i", "<C-S-Left>", function()
  press("<Left>")
  from_insert_to_normal()
  press("v<C-Left>")
end, { desc = "VISUAL left from NORMAL" })

map("i", "<S-Right>", function()
  from_insert_to_normal()
  press("v<Right>")
end, { desc = "VISUAL right from NORMAL" })
map("i", "<C-S-Right>", function()
  from_insert_to_normal()
  press("v<C-Right>")
end, { desc = "VISUAL right from NORMAL" })

map("n", "<S-Up>", "vgk", { desc = "VISUAL up from NORMAL" })
map("n", "<S-Down>", "vgj", { desc = "VISUAL down from NORMAL" })
map("n", "<S-Left>", "v<Left>", { desc = "VISUAL left from NORMAL" })
map("n", "<S-Right>", "v<Right>", { desc = "VISUAL right from NORMAL" })
map("n", "<C-S-Up>", "v<C-Up>", { desc = "VISUAL up from NORMAL" })
map("n", "<C-S-Down>", "v<C-Down>", { desc = "VISUAL down from NORMAL" })
map("n", "<C-S-Left>", "v<C-Left>", { desc = "VISUAL left from NORMAL" })
map("n", "<C-S-Right>", "v<C-Right>", { desc = "VISUAL right from NORMAL" })

map("v", "<S-Up>", "gk")
map("v", "<S-Down>", "gj")
map("v", "<S-Left>", "<Left>")
map("v", "<S-Right>", "<Right>")
map("v", "<C-S-Up>", "<C-Up>")
map("v", "<C-S-Down>", "<C-Down>")
map("v", "<C-S-Left>", "<C-Left>")
map("v", "<C-S-Right>", "<C-Right>")


-- buffers

map({ "n", "i", "v" }, "<C-PageDown>", function()
  require("nvchad.tabufline").next()
end, { desc = "Buffer prev" })
map({ "n", "i", "v" }, "<C-PageUp>", function()
  require("nvchad.tabufline").prev()
end,{ desc = "Buffer next" })

map({ "n", "i", "v" }, "<C-S-PageDown>", function()
  require("nvchad.tabufline").move_buf(1)
end, { desc = "Move buffer right" })
map({ "n", "i", "v" }, "<C-S-PageUp>", function()
  require("nvchad.tabufline").move_buf(-1)
end, { desc = "Move buffer left" })


map({ "n", "i", "v" }, "<C-n>", "<cmd> enew <cr>", { desc = "New buffer" })
map({ "n", "i", "v" }, "<C-q>", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Buffer close" })


-- CMake

map({ "n", "i", "v" }, "<C-b>", "<cmd> CMakeBuild <cr>", { desc = "CMake run" })
map({ "n", "i", "v" }, "<C-r>", "<cmd> CMakeRun <cr>", { desc = "CMake build" })
map({ "n" }, "<leader>cg", "<cmd> CMakeGenerate <cr>", { desc = "CMake generate" })


-- clang-format

map("v", "f", function()
  require("conform").format({
    lsp_fallback = false,
    async = false,
    timeout_ms = 500,
  }, function()
    press("<ESC>")
  end)
end, { desc = "Format selection" })


-- debugger

map("n", "<F5>", function() require("dap").continue() end, { desc = "DAP Continue" })
-- <F17> == SHIFT F5
map("n", "<F17>", function() require("dap").terminate() end, { desc = "DAP Terminate" })
map("n", "<F10>", function() require("dap").step_over() end, { desc = "DAP Step Over" })
map("n", "<F9>", function() require("dap").step_into() end, { desc = "DAP Step Into" })
map("n", "<F12>", function() require("dap").step_out() end, { desc = "DAP Step Out" })

map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
map("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = "DAP Conditional Breakpoint" })

map("n", "<leader>du", function() require("dapui").toggle() end, { desc = "DAP Toggle UI" })
-- map("n", "<leader>dr", function() require("dap").repl.open() end, { desc = "DAP Open REPL" })
