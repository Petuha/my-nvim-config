require "nvchad.mappings"


-- functions

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

local function get_current_buf_index()
  local current_buf = vim.api.nvim_get_current_buf()
  for i, buf_id in ipairs(vim.t.bufs) do
      if buf_id == current_buf then
          return i
      end
  end
  return -1
end

local function open_file_under_the_cursor(mode)
  local file_path = vim.fn.expand("<cfile>")
  -- "^%a+://" - link like "http://..."
  if file_path:match("^%a+://") then
    vim.ui.open(file_path)
    return
  end

  local absolute_path
  if file_path:match("^:/") then
    local clean_path = file_path:sub(3)
    local data_dir = vim.fs.find("data", {
      path = vim.fn.expand("%:p:h"),
      upward = true,
      type = "directory"
    })[1]
    if data_dir then
      absolute_path = data_dir .. "/" .. clean_path
    else
      vim.notify("Directory 'data' not found", vim.log.levels.ERROR)
      return
    end
  elseif file_path:match("^/") then
    absolute_path = file_path
  elseif file_path:match("^~/") then
    absolute_path = vim.fn.expand(file_path)
  else
    absolute_path = vim.fn.expand("%:p:h") .. "/" .. file_path
  end

  if mode == "markup" then
    absolute_path = absolute_path:gsub("images", "markup", 1) .. ".json"
  end

  if not vim.uv.fs_stat(absolute_path) then
    vim.notify("File does not exist: " .. absolute_path, vim.log.levels.WARN)
    return
  end

  if mode == "system" then
    vim.ui.open(absolute_path)
  else
    local bufexists = vim.fn.bufexists(absolute_path) ~= 0
    local current_buf = get_current_buf_index()
    vim.cmd("edit " .. vim.fn.fnameescape(absolute_path))
    local new_buf = get_current_buf_index()
    if bufexists then
      return
    end
    -- opened buffer is in the end -> move it a bit to left
    for _ = 1, new_buf - current_buf - 1 do
        require("nvchad.tabufline").move_buf(-1)
    end
  end
end

local function open_file_under_the_cursor_resolve_mod(open_mode)
  local mode = vim.api.nvim_get_mode().mode
  if mode == "i" then
    from_insert_to_normal()
  end
  open_file_under_the_cursor(open_mode)
  if mode == "i" then
    press("i")
  end
end

local function move_buf(direction, edge)
  local buf_index = get_current_buf_index()
  if buf_index == edge then
    for _ = 1, #vim.t.bufs - 1 do
      require("nvchad.tabufline").move_buf(-direction)
    end
  else
    require("nvchad.tabufline").move_buf(direction)
  end
end

local function move_to_pane(move_keys)
  local keys = move_keys
  local mode = vim.api.nvim_get_mode().mode
  if mode == "i" then
    keys = "<ESC>" .. keys
  elseif mode == "t" then
    keys = "<C-\\><C-n>" .. keys
  elseif mode == "v" then
    keys = "<ESC>" .. keys
  end
  press(keys)
end

local function move_word_left()
  local start_line = vim.fn.line(".")
  press("b")
  vim.schedule(function()
    local cur_line = vim.fn.line(".")
    if cur_line ~= start_line then
      local cur_line_len = #vim.fn.getbufline(vim.api.nvim_get_current_buf(), cur_line)[1]
      vim.api.nvim_win_set_cursor(0, {cur_line, cur_line_len})
    end
  end)
end

local function move_word_right()
  local last_char = is_last_char()
  local start_line = vim.fn.line(".")
  press("e")
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
end



local map = vim.keymap.set


-- base

map("n", ";", ":", { desc = "CMD enter command mod" })
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>", { desc = "Save file" })
-- map({ "n", "i", "v" }, "<C-q>", "<cmd> q <cr>", { desc = "Close window" })
-- map({ "n", "i", "v" }, "<C-e>", function()
--   if vim.api.nvim_get_mode().mode == "i" then
--     vim.cmd("stopinsert")
--   end
--   local api = require("nvim-tree.api")
--   api.tree.toggle()
-- end, { desc = "NvimTree toggle" })
map("n", "<leader>e", function()
  local api = require("nvim-tree.api")
  -- api.tree.toggle({ current_window = true })
  api.tree.toggle()
end, { desc = "NvimTree toggle full screen" })

map({ "n", "i", "v" }, "<C-z>", "<cmd> undo <cr>", { desc = "Change Undo" })
map({ "n", "i", "v" }, "<C-y>", "<cmd> redo <cr>", { desc = "Change Redo" })

map("n", "<C-x>", "i", { desc = "ChangeMod To INSERT" })
map("n", "a", "i", { desc = "ChangeMod To INSERT" })
map("i", "<C-x>", function()
  from_insert_to_normal()
end, { desc = "ChangeMod To NORMAL" })

map("v", "<C-x>", "<ESC>", { desc = "ChangeMod To NORMAL" })
map("v", "<C-c>", "")

map({ "n", "i", "v" }, "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Find in current buffer" })

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
  vim.notify("No recently closed files found.", vim.log.levels.WARN)
end, { desc = "Open last closed file" })


-- navigation

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

map({ "n", "v" }, "<C-Left>", function() move_word_left() end, { desc = "Move word left" })
map({ "n", "v" }, "<C-Right>", function() move_word_right() end, { desc = "Move word right" })

map("i", "<Up>", "<C-o>gk", { desc = "Move up" })
map({ "n", "v" }, "<Up>", "gk", { desc = "Move up" })
map("i", "<Down>", "<C-o>gj", { desc = "Move down" })
map({ "n", "v" }, "<Down>", "gj", { desc = "Move down" })

map("i", "<PageUp>", "<C-o><C-u>", { desc = "Move half page up" })
map("i", "<PageDown>", "<C-o><C-d>", { desc = "Move half page down" })
map({ "n", "v" }, "<PageUp>", "<C-u>", { desc = "Move half page up" })
map({ "n", "v" }, "<PageDown>", "<C-d>", { desc = "Move half page down" })
map({ "n", "i", "v" }, "<C-u>", "")
map("v", "<C-d>", "")

map({ "n", "i", "v" }, "<C-Up>", "<cmd>normal! <C-y><cr>", { desc = "Move screen up" })
map({ "n", "i", "v" }, "<C-Down>", "<cmd>normal! <C-e><cr>", { desc = "Move screen down" })

map({ "n", "i" }, "<F4>", function() open_file_under_the_cursor_resolve_mod("default") end, { desc = "Open File under the cursor in new buffer" })
map({ "n", "i" }, "<F3>", function() open_file_under_the_cursor_resolve_mod("system") end, { desc = "Open File under the cursor with default app" })
map({ "n", "i" }, "<F1>", function() open_file_under_the_cursor_resolve_mod("markup") end, { desc = "Open Markup under the cursor in new buffer" })

map("n", "<End>", function()
  if not (is_first_char() and is_last_char()) then
    press("<End><Right>")
  else
    press("<End>")
  end
end)


-- editing

map("n", "<Del>", "")
map("n", "<C-Del>", "")
map("n", "<S-Del>", "")
map("n", "<C-S-Del>", "")

map("n", "D", "\"_D")
map({ "n", "v" }, "d", "\"_d")

map("i", "<C-H>", "<C-w>", { desc = "Delete previous word with Ctrl + Backspace" })
-- map("n", "<C-H>", "a<C-w><ESC>", { desc = "Delete previous word with Ctrl + Backspace" })

map("i", "<C-Del>", "<C-o>\"_dw", { desc = "Delete next word with Ctrl + Delete" })
-- map("n", "<C-Del>", "dw", { desc = "Delete next word with Ctrl + Delete" })

map({ "n", "i" }, "<C-d>", "<cmd> delete _ <cr>", { desc = "EDIT Delete current line" })
map({ "n", "i" }, "<C-c>", "<cmd> t. <cr>", { desc = "EDIT Duplicate current line" })


-- NORMAL mod

map("n", "d", '"_d')
map("n", "xx", 'dd')
map("n", "cc", 'yy')
-- map("n", "c", 'y')
map("n", "x", 'd')
-- map("n", "<C-l>", "<C-w>")


-- VISUAL mod

map("v", "<BS>", '"_d', { desc = "VISUAL delete selection" })
map("v", "<Del>", '"_d', { desc = "VISUAL delete selection" })
map("v", "d", '"_d', { desc = "VISUAL delete selection" })

map({ "n", "i", "v" }, "<C-a>", "<ESC>ggVG", { desc = "VISUAL select all" })

map("v", "c", '"+ygv<ESC>', { desc = "VISUAL copy" })
map("v", "x", '"+x', { desc = "VISUAL cut" })
map("v", "p", '"_dP', { desc = "VISUAL paste" })
map("v", "P", '"_dP', { desc = "VISUAL paste" })

map("i", "<S-Up>", "<C-o>vgko<Left>o", { desc = "VISUAL up from NORMAL" })
map("i", "<C-S-Up>", "<C-o>v<C-Up>o<Left>o", { desc = "VISUAL up from NORMAL" })
map("i", "<S-Down>", "<C-o>vgj", { desc = "VISUAL down from NORMAL" })
map("i", "<C-S-Down>", "<C-o>v<C-Down>", { desc = "VISUAL down from NORMAL" })

map("i", "<S-Left>", "<C-o>v<Left>oho", { desc = "VISUAL left from NORMAL" })
map("i", "<C-S-Left>", function()
  press("<C-o>v")
  move_word_left()
  press("oho")
end, { desc = "VISUAL left from NORMAL" })

map("i", "<S-Right>", "<C-o>v", { desc = "VISUAL right from NORMAL" })
map("i", "<C-S-Right>", function()
  press("<C-o>v")
  move_word_right()
end, { desc = "VISUAL right from NORMAL" })

map("n", "<S-Up>", "vgk", { desc = "VISUAL up from NORMAL" })
map("n", "<S-Down>", "vgj", { desc = "VISUAL down from NORMAL" })
map("n", "<S-Left>", "v<Left>", { desc = "VISUAL left from NORMAL" })
map("n", "<S-Right>", "v<Right>", { desc = "VISUAL right from NORMAL" })
map("n", "<C-S-Up>", "v<C-Up>", { desc = "VISUAL up from NORMAL" })
map("n", "<C-S-Down>", "v<C-Down>", { desc = "VISUAL down from NORMAL" })
map("n", "<C-S-Left>", function()
  press("v")
  move_word_left()
end, { desc = "VISUAL left from NORMAL" })
map("n", "<C-S-Right>", function()
  press("v")
  move_word_right()
end, { desc = "VISUAL right from NORMAL" })

map("v", "<S-Up>", "gk")
map("v", "<S-Down>", "gj")
map("v", "<S-Left>", "<Left>")
map("v", "<S-Right>", "<Right>")
map("v", "<C-S-Up>", "<C-Up>")
map("v", "<C-S-Down>", "<C-Down>")
map("v", "<C-S-Left>", function() move_word_left() end)
map("v", "<C-S-Right>", function() move_word_right() end)

map("v", "<", "<gv")
map("v", ">", ">gv")


-- buffers

map({ "n", "i", "t" }, "<C-PageDown>", function()
  require("nvchad.tabufline").next()
end, { desc = "Buffer prev" })
map({ "n", "i", "t" }, "<C-PageUp>", function()
  require("nvchad.tabufline").prev()
end,{ desc = "Buffer next" })

map({ "n", "i", "t" }, "<C-S-PageDown>", function() move_buf(1, #vim.t.bufs) end, { desc = "Move buffer right" })
map({ "n", "i", "t" }, "<C-S-PageUp>", function() move_buf(-1, 1) end, { desc = "Move buffer left" })

map({ "n", "i" }, "<C-n>", "<cmd> enew <cr>", { desc = "New buffer" })
map({ "n", "i" }, "<C-q>", function() require("nvchad.tabufline").close_buffer() end, { desc = "Buffer close", nowait = true })


-- panes

map({ "n", "i", "v", "t" }, "<M-Left>", function() move_to_pane("<C-w>h") end, { desc = "Pane Move to left" })
map({ "n", "i", "v", "t" }, "<M-Down>", function() move_to_pane("<C-w>j") end, { desc = "Pane Move to lower" })
map({ "n", "i", "v", "t" }, "<M-Up>", function() move_to_pane("<C-w>k") end, { desc = "Pane Move to upper" })
map({ "n", "i", "v", "t" }, "<M-Right>", function() move_to_pane("<C-w>l") end, { desc = "Pane Move to right" })

local resize_step = 3

map({ "n", "i", "v", "t" }, "<M-C-Left>", function()
  local cur_win = vim.api.nvim_get_current_win()
  if vim.fn.win_screenpos(cur_win)[2] > 1 and vim.fn.winnr('l') == vim.fn.winnr() then
    vim.cmd("vertical resize +" .. resize_step)
  else
    vim.cmd("vertical resize -" .. resize_step)
  end
end, { desc = "Pane Resize to left" })

map({ "n", "i", "v", "t" }, "<M-C-Right>", function()
  local cur_win = vim.api.nvim_get_current_win()
  if vim.fn.win_screenpos(cur_win)[2] > 1 and vim.fn.winnr('l') == vim.fn.winnr() then
    vim.cmd("vertical resize -" .. resize_step)
  else
    vim.cmd("vertical resize +" .. resize_step)
  end
end, { desc = "Pane Resize to right" })

map({ "n", "i", "v", "t" }, "<M-C-Up>", function()
  if vim.fn.winnr('j') == vim.fn.winnr() then
    vim.cmd("resize +" .. resize_step)
  else
    vim.cmd("resize -" .. resize_step)
  end
end, { desc = "Pane Resize to upper" })

map({ "n", "i", "v", "t" }, "<M-C-Down>", function()
  if vim.fn.winnr('j') == vim.fn.winnr() then
    vim.cmd("resize -" .. resize_step)
  else
    vim.cmd("resize +" .. resize_step)
  end
end, { desc = "Pane Resize to lower" })


-- CMake

map({ "n", "i", "v" }, "<C-b>", "<cmd> CMakeBuild <cr>", { desc = "CMake run" })
map({ "n", "i", "v" }, "<C-r>", "<cmd> CMakeRun <cr>", { desc = "CMake build" })
map({ "n" }, "<leader>cg", "<cmd> CMakeGenerate <cr>", { desc = "CMake generate" })
map({ "n" }, "<leader>cd", "<cmd> CMakeDebug <cr>", { desc = "CMake debug" })


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
