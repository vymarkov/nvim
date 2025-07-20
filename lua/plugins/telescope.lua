local M = {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
}

M.config = function()
  local telescope = require("telescope")
  local builtin = require("telescope.builtin")

  -- Telescope setup
  telescope.setup({
    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      file_ignore_patterns = {
        "node_modules",
        ".git/",
        "dist/",
        "build/",
        "coverage/",
        "public/",
      },
      mappings = {
        i = {
          ["<C-q>"] = require("telescope.actions").send_selected_to_qflist + require("telescope.actions").open_qflist,
          ["<C-a>"] = require("telescope.actions").select_all,
        },
      },
    },
    pickers = {
      oldfiles = {
        prompt_title = "Recently Opened Files",
        cwd_only = true,
      },
    },
  })

  -- Load fzf extension for better performance
  telescope.load_extension("fzf")

  -- Keymap for recently opened files
  nmap("<leader>fr", builtin.oldfiles, { desc = "Find Recently Opened Files" })
end

return M
