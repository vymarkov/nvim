local core_plugins = require("plugins.dap.core")
local typescript_plugins = require("plugins.dap.typescript")

-- Combine both plugin arrays
local plugins = {}
vim.list_extend(plugins, core_plugins)
vim.list_extend(plugins, typescript_plugins)

return plugins

