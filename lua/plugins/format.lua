return {
  "stevearc/conform.nvim",
  event = {
    "BufReadPre",
    "BufNewFile",
  },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        html = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier" },
        markdown = { "prettierd", "prettier" },
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        hcl = { "hcl" },
        terraform = { "hcl" },
        toml = { "taplo" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
        async = false,
      },
      notify_on_error = false,
    })
    vim.api.nvim_set_keymap(
      "n",
      "<leader>cf",
      '<cmd>lua require("conform").format()<CR>',
      { noremap = true, silent = true }
    )
  end,
}
