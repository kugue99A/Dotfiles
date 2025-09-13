-- TypeScript Language Server configuration
-- Modern ts_ls (successor to tsserver) configuration following Neovim LSP docs

return {
  -- Command to start the language server
  cmd = { "typescript-language-server", "--stdio" },
  
  -- File types this server will attach to
  filetypes = { 
    "javascript", 
    "javascriptreact", 
    "typescript", 
    "typescriptreact" 
  },
  
  -- Root directory markers to detect project root
  root_markers = { 
    "package.json", 
    "tsconfig.json", 
    "jsconfig.json",
    ".git" 
  },
  
  -- Single file support
  single_file_support = true,
  
  -- Initialization options
  init_options = {
    preferences = {
      disableSuggestions = false,
      quotePreference = "auto",
      includeCompletionsForModuleExports = true,
      includeCompletionsForImportStatements = true,
      includeCompletionsWithSnippetText = true,
      includeAutomaticOptionalChainCompletions = true,
    },
    -- Plugins to load
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vim.fn.expand("~/.npm-global/lib/node_modules/@vue/typescript-plugin"),
        languages = { "vue" }
      }
    }
  },
  
  -- TypeScript-specific settings
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "literal", -- 'none' | 'literals' | 'all'
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = false,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      -- Suggest configuration
      suggest = {
        includeCompletionsForModuleExports = true,
        includeAutomaticOptionalChainCompletions = true,
      },
      -- Preferences
      preferences = {
        includePackageJsonAutoImports = "auto", -- 'auto' | 'on' | 'off'
        useAliasesForRenames = true,
      },
      -- Code actions
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
        showOnAllFunctions = false,
      },
      -- Formatting (handled by external formatters usually)
      format = {
        enable = false, -- Use external formatters like Prettier
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all", -- More aggressive for JS
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      suggest = {
        includeCompletionsForModuleExports = true,
        includeAutomaticOptionalChainCompletions = true,
      },
      preferences = {
        includePackageJsonAutoImports = "auto",
        useAliasesForRenames = true,
      },
      format = {
        enable = false, -- Use external formatters
      },
    },
    -- Workspace configuration
    completions = {
      completeFunctionCalls = true,
    },
    -- Diagnostics
    diagnostics = {
      ignoredCodes = {},
    },
  },
  
  -- Custom handlers (optional)
  handlers = {
    -- Handle workspace/configuration requests
    ["workspace/configuration"] = function(_, result, ctx)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if not client then return {} end
      
      local settings = client.config.settings or {}
      local response = {}
      
      for _, item in ipairs(result) do
        if item.section then
          local section_keys = vim.split(item.section, ".", { plain = true })
          local value = settings
          for _, key in ipairs(section_keys) do
            value = value[key]
            if not value then break end
          end
          table.insert(response, value or vim.NIL)
        else
          table.insert(response, settings)
        end
      end
      
      return response
    end,
  },
  
  -- Custom on_attach function (optional, can be overridden)
  on_attach = function(client, bufnr)
    -- Disable formatting if using external formatter
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    
    -- Enable inlay hints if available
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
    
    -- Custom commands
    vim.api.nvim_buf_create_user_command(bufnr, "TypescriptOrganizeImports", function()
      vim.lsp.buf.execute_command({
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
      })
    end, { desc = "Organize imports" })
    
    vim.api.nvim_buf_create_user_command(bufnr, "TypescriptRenameFile", function()
      local old_name = vim.api.nvim_buf_get_name(0)
      local new_name = vim.fn.input("New name: ", old_name)
      if new_name ~= "" and new_name ~= old_name then
        vim.lsp.buf.execute_command({
          command = "_typescript.renameFile",
          arguments = {
            {
              oldUri = vim.uri_from_fname(old_name),
              newUri = vim.uri_from_fname(new_name),
            },
          },
        })
      end
    end, { desc = "Rename file" })
    
    vim.api.nvim_buf_create_user_command(bufnr, "TypescriptAddMissingImports", function()
      vim.lsp.buf.execute_command({
        command = "_typescript.addMissingImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
      })
    end, { desc = "Add missing imports" })
    
    vim.api.nvim_buf_create_user_command(bufnr, "TypescriptRemoveUnusedImports", function()
      vim.lsp.buf.execute_command({
        command = "_typescript.removeUnusedImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
      })
    end, { desc = "Remove unused imports" })
  end,
  
  -- Capabilities (will be merged with default capabilities in core/lsp.lua)
  capabilities = {
    workspace = {
      configuration = true,
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
}