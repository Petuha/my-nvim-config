local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    -- css = { "prettier" },
    -- html = { "prettier" },
    cpp = { "clang-format" },
    c = { "clang-format" },
  },

  formatters = {
    ["clang-format"] = {
      prepend_args = {
        "--style={ \
          BasedOnStyle: Google, \
          UseTab: Never, \
          IndentWidth: 2, \
          TabWidth: 4, \
          AccessModifierOffset: -2, \
          IndentCaseLabels: false, \
          AlignAfterOpenBracket: Align, \
          PointerAlignment: Left, \
          BreakBeforeBraces: Attach, \
          AllowShortBlocksOnASingleLine: true, \
          KeepEmptyLinesAtTheStartOfBlocks: true \
        }",
      },
    },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
