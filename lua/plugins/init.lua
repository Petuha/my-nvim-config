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
      renderer = {
        root_folder_label = ":p",
        full_name = true,
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.del("n", "<C-e>", { buffer = bufnr })
        vim.keymap.set("n", "<C-f>", function()
          require("telescope.builtin").find_files()
        end, { buffer = bufnr, noremap = true })
      end
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
      vim.api.nvim_set_hl(0, "NvimTreeRootFolder", { link = "NvimTreeFolderName" })
    end,
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
      -- fix breaking shortcut
      local function reset_cw_mapping()
        vim.keymap.set({ "n", "i" }, "<C-w>", function() require("nvchad.tabufline").close_buffer() end, { desc = "Buffer close", nowait = true })
      end
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
        reset_cw_mapping()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
        reset_cw_mapping()
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

  {
    "nvim-telescope/telescope.nvim",
    --dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = function()
      return require "configs.telescope"
    end,
  },

  {
    "mikavilpas/yazi.nvim",
    version = "26.1.22",
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      {
        mode = { "n", "i", "v" },
        "<C-e>",
        "<cmd>Yazi cwd<cr>",
        desc = "Resume the last yazi session",
      },
    },
    opts = {
      open_for_directories = false,
      change_neovim_cwd_on_close = true,
      keymaps = {
        show_help = "g?",
      },
    },
    init = function()
    end,
  }

}
