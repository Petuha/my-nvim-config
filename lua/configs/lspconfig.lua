require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "clangd" }
vim.lsp.enable(servers)
vim.lsp.config.clangd = {
  cmd = {
    'clangd',
    '--background-index',
    "--clang-tidy",
  --  "--compile-commands-dir=build",
  },
  root_markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
}

-- read :h vim.lsp.config for changing options of lsp servers 
