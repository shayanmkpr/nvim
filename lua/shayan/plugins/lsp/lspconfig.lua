return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
    { "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  },
  config = function()
    -- Import plugins with error handling
    local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
    if not ok_lspconfig then
      vim.notify("Failed to load lspconfig", vim.log.levels.ERROR)
      return
    end

    local ok_mason, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not ok_mason then
      vim.notify("Failed to load mason-lspconfig", vim.log.levels.ERROR)
      return
    end

    local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if not ok_cmp then
      vim.notify("Failed to load cmp-nvim-lsp", vim.log.levels.ERROR)
      return
    end

    -- Setup Trouble.nvim for enhanced diagnostics
    local ok_trouble, trouble = pcall(require, "trouble")
    if ok_trouble then
      trouble.setup({
        position = "bottom",
        height = 10,
        width = 50,
        icons = true,
        mode = "workspace_diagnostics",
        severity = nil,
        fold_open = "",
        fold_closed = "",
        group = true,
        padding = true,
        cycle_results = true,
        action_keys = {
          close = "q",
          cancel = "<esc>",
          refresh = "r",
          jump = { "<cr>", "<tab>", "<2-leftmouse>" },
          open_split = { "<c-x>" },
          open_vsplit = { "<c-v>" },
          open_tab = { "<c-t>" },
          jump_close = { "o" },
          toggle_mode = "m",
          switch_severity = "s",
          toggle_preview = "P",
          hover = "K",
          preview = "p",
          open_code_href = "c",
          close_folds = { "zM", "zm" },
          open_folds = { "zR", "zr" },
          toggle_fold = { "zA", "za" },
          previous = "k",
          next = "j",
          help = "?"
        },
        multiline = true,
        indent_lines = true,
        win_config = { border = "single" },
        auto_open = false,
        auto_close = false,
        auto_preview = true,
        auto_fold = false,
        auto_jump = { "lsp_definitions" },
        include_declaration = true,
        signs = {
          error = "",
          warning = "",
          hint = "",
          information = "",
          other = "",
        },
        use_diagnostic_signs = false
      })
    end

    local keymap = vim.keymap

    -- Enhanced LSP attach function with better error handling
    local function on_attach(client, bufnr)
      -- Buffer local mappings with error handling
      local opts = { buffer = bufnr, silent = true, noremap = true }

      -- Helper function to set keymap with error handling
      local function set_keymap(mode, lhs, rhs, desc)
        opts.desc = desc
        local success, err = pcall(keymap.set, mode, lhs, rhs, opts)
        if not success then
          vim.notify("Failed to set keymap " .. lhs .. ": " .. err, vim.log.levels.WARN)
        end
      end

      -- LSP keybindings
      set_keymap("n", "gR", "<cmd>Telescope lsp_references<CR>", "Show LSP references")
      set_keymap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
      set_keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Show LSP definitions")
      set_keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", "Show LSP implementations")
      set_keymap("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", "Show LSP type definitions")
      set_keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "See available code actions")
      set_keymap("n", "<leader>rn", vim.lsp.buf.rename, "Smart rename")
      set_keymap("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Show buffer diagnostics")
      set_keymap("n", "<leader>d", vim.diagnostic.open_float, "Show line diagnostics")
      set_keymap("n", "[d", vim.diagnostic.goto_prev, "Go to previous diagnostic")
      set_keymap("n", "]d", vim.diagnostic.goto_next, "Go to next diagnostic")
      set_keymap("n", "K", vim.lsp.buf.hover, "Show documentation for what is under cursor")
      set_keymap("n", "<leader>rs", ":LspRestart<CR>", "Restart LSP")
      
      -- Additional useful keybindings
      set_keymap("n", "<leader>dl", "<cmd>Telescope diagnostics<CR>", "Show workspace diagnostics")
      set_keymap("n", "<leader>ws", "<cmd>Telescope lsp_workspace_symbols<CR>", "Show workspace symbols")
      set_keymap("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<CR>", "Show document symbols")

      -- Enhanced diagnostics keybindings (Trouble.nvim or fallback)
      if ok_trouble then
        set_keymap("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics (Trouble)")
        set_keymap("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Buffer Diagnostics (Trouble)")
        set_keymap("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", "Symbols (Trouble)")
        set_keymap("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "LSP Definitions / references")
        set_keymap("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", "Location List (Trouble)")
        set_keymap("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", "Quickfix List (Trouble)")
      end

      -- Navigate diagnostics with better feedback
      set_keymap('n', '<leader>dn', function()
        vim.diagnostic.goto_next({ severity = { min = vim.diagnostic.severity.WARN } })
        vim.diagnostic.open_float()
      end, "Next diagnostic")

      set_keymap('n', '<leader>dp', function()
        vim.diagnostic.goto_prev({ severity = { min = vim.diagnostic.severity.WARN } })
        vim.diagnostic.open_float()
      end, "Previous diagnostic")

      -- Show all diagnostics in telescope
      set_keymap('n', '<leader>da', '<cmd>Telescope diagnostics<cr>', "All diagnostics")
      set_keymap('n', '<leader>db', '<cmd>Telescope diagnostics bufnr=0<cr>', "Buffer diagnostics")

      -- Filter diagnostics by severity
      set_keymap('n', '<leader>de', function()
        vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
        vim.cmd("copen")
      end, "Error diagnostics")

      set_keymap('n', '<leader>dw', function()
        vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.WARN })
        vim.cmd("copen")
      end, "Warning diagnostics")

      -- Enable inlay hints if available (Neovim 0.10+)
      if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
        set_keymap("n", "<leader>ih", function()
          vim.lsp.inlay_hint.enable(bufnr, not vim.lsp.inlay_hint.is_enabled(bufnr))
        end, "Toggle inlay hints")
      end

      -- Auto-format on save if client supports it
      if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          group = vim.api.nvim_create_augroup("LspFormat_" .. bufnr, { clear = true }),
          callback = function()
            vim.lsp.buf.format({ 
              bufnr = bufnr,
              timeout_ms = 3000,
              filter = function(format_client)
                -- Prefer specific formatters over LSP formatting
                local preferred_formatters = { "null-ls", "conform" }
                for _, formatter in ipairs(preferred_formatters) do
                  if format_client.name == formatter then
                    return true
                  end
                end
                return format_client.name == client.name
              end
            })
          end,
        })
      end

      -- Highlight references under cursor
      if client.server_capabilities.documentHighlightProvider then
        local highlight_group = vim.api.nvim_create_augroup("LSPDocumentHighlight_" .. bufnr, { clear = true })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          buffer = bufnr,
          group = highlight_group,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
          buffer = bufnr,
          group = highlight_group,
          callback = vim.lsp.buf.clear_references,
        })
      end
    end

    -- LSP attach autocmd with better error handling
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client then
          on_attach(client, ev.buf)
        end
      end,
    })

    -- Enhanced capabilities
    local capabilities = cmp_nvim_lsp.default_capabilities()
    
    -- Add additional capabilities
    capabilities.textDocument.completion.completionItem = {
      documentationFormat = { "markdown", "plaintext" },
      snippetSupport = true,
      preselectSupport = true,
      insertReplaceSupport = true,
      labelDetailsSupport = true,
      deprecatedSupport = true,
      commitCharactersSupport = true,
      tagSupport = { valueSet = { 1 } },
      resolveSupport = {
        properties = {
          "documentation",
          "detail",
          "additionalTextEdits",
        },
      },
    }

    -- Configure diagnostics with better settings
    vim.diagnostic.config({
      virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN },
        source = "if_many",
        spacing = 4,
        prefix = "●",
        format = function(diagnostic)
          local severity = vim.diagnostic.severity[diagnostic.severity]
          return string.format("[%s] %s: %s", severity, diagnostic.source or "LSP", diagnostic.message)
        end,
      },
      float = {
        source = "always",
        border = "rounded",
        header = "Diagnostics",
        prefix = function(diagnostic, i, total)
          local severity = vim.diagnostic.severity[diagnostic.severity]
          local icon = severity == "ERROR" and "" or 
                      severity == "WARN" and "" or
                      severity == "INFO" and "" or ""
          return string.format("%d/%d %s ", i, total, icon)
        end,
        format = function(diagnostic)
          return string.format("[%s] %s\n%s", 
            diagnostic.source or "LSP", 
            diagnostic.message,
            diagnostic.code and ("Code: " .. diagnostic.code) or ""
          )
        end,
        max_width = 80,
        max_height = 20,
      },
      signs = {
        severity = { min = vim.diagnostic.severity.HINT },
      },
      underline = {
        severity = { min = vim.diagnostic.severity.WARN },
      },
      update_in_insert = false,
      severity_sort = true,
    })

    -- Enhanced diagnostic symbols
    local signs = { 
      Error = "󰅚 ", 
      Warn = "󰀪 ", 
      Hint = "󰌶 ", 
      Info = "󰋽 " 
    }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- LSP server configurations with error handling
    local server_configs = {
      svelte = function()
        lspconfig.svelte.setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            on_attach(client, bufnr)
            
            -- Svelte-specific autocmd with error handling
            vim.api.nvim_create_autocmd("BufWritePost", {
              pattern = { "*.js", "*.ts" },
              group = vim.api.nvim_create_augroup("SvelteReload", { clear = true }),
              callback = function(ctx)
                if client and client.notify then
                  local success, err = pcall(client.notify, "$/onDidChangeTsOrJsFile", { uri = ctx.match })
                  if not success then
                    vim.notify("Svelte notify failed: " .. err, vim.log.levels.WARN)
                  end
                end
              end,
            })
          end,
        })
      end,

      graphql = function()
        lspconfig.graphql.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
          root_dir = lspconfig.util.root_pattern(
            ".graphqlrc*",
            ".graphql.config.*",
            "graphql.config.*",
            "package.json"
          ),
        })
      end,

      emmet_ls = function()
        lspconfig.emmet_ls.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = { 
            "html", "typescriptreact", "javascriptreact", 
            "css", "sass", "scss", "less", "svelte", "vue" 
          },
        })
      end,

      lua_ls = function()
        lspconfig.lua_ls.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
              completion = {
                callSnippet = "Replace",
              },
              hint = {
                enable = true,
              },
            },
          },
        })
      end,
    }

    -- Setup handlers with better error handling
    local ok_setup, err = pcall(mason_lspconfig.setup_handlers, {
      -- Default handler for installed servers
      function(server_name)
        local success, setup_err = pcall(lspconfig[server_name].setup, {
          capabilities = capabilities,
          on_attach = on_attach,
        })
        if not success then
          vim.notify("Failed to setup LSP server " .. server_name .. ": " .. setup_err, vim.log.levels.ERROR)
        end
      end,

      -- Custom server configurations
      svelte = server_configs.svelte,
      graphql = server_configs.graphql,
      emmet_ls = server_configs.emmet_ls,
      lua_ls = server_configs.lua_ls,
    })

    if not ok_setup then
      vim.notify("Failed to setup mason handlers: " .. err, vim.log.levels.ERROR)
    end

    -- Auto-commands for better diagnostics experience
    local diag_group = vim.api.nvim_create_augroup("DiagnosticsConfig", { clear = true })
    
    -- Auto-show diagnostics in floating window when cursor holds
    vim.api.nvim_create_autocmd("CursorHold", {
      group = diag_group,
      callback = function()
        local opts = {
          focusable = false,
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          border = "rounded",
          source = "always",
          prefix = " ",
          scope = "cursor",
        }
        vim.diagnostic.open_float(nil, opts)
      end,
    })

    -- Custom diagnostic commands
    vim.api.nvim_create_user_command("DiagnosticsList", function()
      if ok_trouble then
        vim.cmd("Trouble diagnostics toggle")
      else
        vim.cmd("lua vim.diagnostic.setloclist()")
      end
    end, { desc = "Toggle diagnostics list" })

    vim.api.nvim_create_user_command("DiagnosticsBuffer", function()
      if ok_trouble then
        vim.cmd("Trouble diagnostics toggle filter.buf=0")
      else
        vim.diagnostic.setloclist({ severity = { min = vim.diagnostic.severity.WARN } })
      end
    end, { desc = "Toggle buffer diagnostics" })

    vim.api.nvim_create_user_command("DiagnosticsQuickfix", function()
      vim.diagnostic.setqflist({ severity = { min = vim.diagnostic.severity.WARN } })
      vim.cmd("copen")
    end, { desc = "Send diagnostics to quickfix" })

    -- Add command to show LSP info
    vim.api.nvim_create_user_command("LspInfo", function()
      vim.cmd("LspInfo")
    end, { desc = "Show LSP information" })

    -- Add command to toggle diagnostics
    vim.api.nvim_create_user_command("DiagnosticsToggle", function()
      vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    end, { desc = "Toggle diagnostics" })

    -- Toggle virtual text
    local virtual_text_enabled = true
    vim.api.nvim_create_user_command("DiagnosticsVirtualTextToggle", function()
      virtual_text_enabled = not virtual_text_enabled
      vim.diagnostic.config({
        virtual_text = virtual_text_enabled and {
          severity = { min = vim.diagnostic.severity.WARN },
          source = "if_many",
          spacing = 4,
          prefix = "●",
        } or false
      })
      vim.notify("Virtual text " .. (virtual_text_enabled and "enabled" or "disabled"))
    end, { desc = "Toggle virtual text" })

    -- Global keymaps for virtual text toggle
    keymap.set('n', '<leader>dt', function()
      vim.cmd("DiagnosticsVirtualTextToggle")
    end, { desc = "Toggle virtual text", noremap = true, silent = true })
  end,
}
