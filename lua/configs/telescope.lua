local opts = require "nvchad.configs.telescope"
opts.defaults.mappings = opts.defaults.mappings or {}
opts.defaults.mappings.i = opts.defaults.mappings.i or {}
opts.defaults.mappings.n = opts.defaults.mappings.n or {}
opts.defaults.mappings.i["<C-f>"] = function(...)
  return require("telescope.actions").close(...)
end
opts.defaults.mappings.n["<C-f>"] = function(...)
  return require("telescope.actions").close(...)
end
return opts
