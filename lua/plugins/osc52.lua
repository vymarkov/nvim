return {
  "ojroques/nvim-osc52",
  event = "VeryLazy",
  config = function()
    local osc52 = require("osc52")
    
    osc52.setup({
      max_length = 0,      -- Maximum length of selection (0 for no limit)
      silent = false,      -- Disable message on successful copy
      trim = false,        -- Trim surrounding whitespaces before copy
      tmux_passthrough = true, -- Use tmux passthrough (requires tmux: set -g allow-passthrough on)
    })

    -- Function to check if we're in an SSH session
    local function is_ssh()
      return os.getenv("SSH_TTY") ~= nil or os.getenv("SSH_CLIENT") ~= nil or os.getenv("SSH_CONNECTION") ~= nil
    end

    local function is_devpod()
      return os.getenv("DEVPOD") ~= nil
    end

    local function is_remote_session()
      return is_ssh() or is_devpod()
    end

    -- Custom copy function that uses OSC52 when in SSH, otherwise uses system clipboard
    local function smart_copy(text)
      if is_remote_session() then
        osc52.copy(text)
      else
        vim.fn.setreg("+", text)
      end
    end

    -- Override the default yank behavior to use OSC52 in SSH sessions
    vim.api.nvim_create_autocmd("TextYankPost", {
      group = vim.api.nvim_create_augroup("OSC52Yank", { clear = true }),
      callback = function()
        local event = vim.v.event
        if event.operator == "y" and event.regname == "" then
          local yanked_text = table.concat(event.regcontents, "\n")
          if is_remote_session() then
            osc52.copy(yanked_text)
          end
        end
      end,
    })

    -- Key mappings for manual OSC52 copy
    vim.keymap.set("n", "<leader>c", function()
      smart_copy(vim.fn.getreg('"'))
    end, { desc = "Copy last yank to system clipboard" })

    vim.keymap.set("v", "<leader>c", function()
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")
      local lines = vim.fn.getline(start_pos[2], end_pos[2])
      
      if #lines == 1 then
        lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
      else
        lines[1] = string.sub(lines[1], start_pos[3])
        lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
      end
      
      local text = table.concat(lines, "\n")
      smart_copy(text)
      print("Copied selection to system clipboard")
    end, { desc = "Copy selection to system clipboard" })

    -- Command to manually trigger OSC52 copy
    vim.api.nvim_create_user_command("OSC52Copy", function(opts)
      if opts.range == 2 then
        -- Range was provided, copy the range
        local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
        local text = table.concat(lines, "\n")
        osc52.copy(text)
        print("Copied " .. opts.line2 - opts.line1 + 1 .. " lines to system clipboard")
      else
        -- No range, copy current line
        local line = vim.api.nvim_get_current_line()
        osc52.copy(line)
        print("Copied current line to system clipboard")
      end
    end, { range = true, desc = "Copy text using OSC52" })
  end,
} 