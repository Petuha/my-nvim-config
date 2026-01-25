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
      conf.mapping["<Up>"] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.select_prev_item() else fallback() end
      end)
      conf.mapping["<Down>"] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.select_next_item() else fallback() end
      end)

      return conf
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)

      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"

      npairs.add_rules {
        Rule("<", ">")
        -- Проверять, есть ли символ перед курсором, и если это '>', просто переместить курсор
        :with_move(function(opts)
          return opts.char == ">"
        end)
        -- Не создавать пару, если следующий символ уже '>'
        :with_pair(cond.not_after_text ">"),
      }
    end,
  },

}
