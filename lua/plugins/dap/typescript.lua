return {
  {
    'mfussenegger/nvim-dap',
    optional = true,
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          table.insert(opts.ensure_installed, 'js-debug-adapter')
        end,
      },
    },
    opts = function()
      local dap = require 'dap'
      if not dap.adapters['pwa-node'] then
        -- Get mason path
        local mason_path = vim.env.MASON or (vim.fn.stdpath('data') .. '/mason')
        local js_debug_path = mason_path
          .. '/packages/'
          .. 'js-debug-adapter'
          .. '/js-debug/src/dapDebugServer.js'

        require('dap').adapters['pwa-node'] = {
          type = 'server',
          host = '127.0.0.1',
          port = '${port}',
          executable = {
            command = 'node',
            args = {
              js_debug_path,
              '${port}',
              '127.0.0.1',
            },
          },
        }
      end
      if not dap.adapters['node'] then
        dap.adapters['node'] = function(cb, config)
          if config.type == 'node' then
            config.type = 'pwa-node'
          end
          local nativeAdapter = dap.adapters['pwa-node']
          if type(nativeAdapter) == 'function' then
            nativeAdapter(cb, config)
          else
            cb(nativeAdapter)
          end
        end
      end

      local js_filetypes =
        { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }

      local vscode = require 'dap.ext.vscode'
      vscode.type_to_filetypes['node'] = js_filetypes
      vscode.type_to_filetypes['pwa-node'] = js_filetypes

      for _, language in ipairs(js_filetypes) do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = 'pwa-node',
              request = 'launch',
              name = 'Launch file',
              program = '${file}',
              cwd = '${workspaceFolder}',
            },
            {
              type = 'pwa-node',
              request = 'attach',
              name = 'Attach',
              processId = require('dap.utils').pick_process,
              cwd = '${workspaceFolder}',
            },
          }
        end
      end
    end,
  },
}

