return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "Wansmer/langmapper.nvim",
    lazy = false,
    priority = 999,
    config = function()
      require("langmapper").setup({})
    end,
  },
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      local translate_key = require("langmapper.utils").translate_keycode
      -- don't show mappings translated by langmapper.nvim. Show entry if func returns true
      opts.filter = function(mapping)
        return mapping.lhs
          and mapping.lhs == translate_key(mapping.lhs, "default", "ru")
          and mapping.desc
          and mapping.desc:find("LM") == nil
      end
    end,
  },
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, _)
      local translate_key = require("langmapper.utils").translate_keycode
      local normkey_orig = Snacks.util.normkey
      Snacks.util.normkey = function(key)
        if key then
          key = translate_key(key, "default", "ru")
        end
        return normkey_orig(key)
      end
    end,
  },

  {
    'Civitasv/cmake-tools.nvim',
    lazy = false,
    opts = {}
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.del("n", "<C-e>", { buffer = bufnr })
        vim.keymap.set("n", "<C-e>", api.tree.toggle, opts("Toggle"))
      end,
    },
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {},
    },
  },

  {
    "mfussenegger/nvim-dap",
    config = function()
      require("configs.dap")
    end,
  },

  {
    "nvim-neotest/nvim-nio",
  },

  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function()
      local conf = require "nvchad.configs.cmp"
      local cmp = require "cmp"

      conf.mapping["<Tab>"] = cmp.mapping.confirm({ select = true })
      conf.mapping["<CR>"] = cmp.mapping(function(fallback) fallback() end)
      conf.mapping["<Esc>"] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.close() else fallback() end
      end)
      conf.mapping["<C-Up>"] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.select_prev_item() else fallback() end
      end)
      conf.mapping["<C-Down>"] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.select_next_item() else fallback() end
      end)

      return conf
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = require "configs.treesitter",
  },

  {
    "mason-org/mason.nvim",
    opts = require "configs.mason"
  },

}
