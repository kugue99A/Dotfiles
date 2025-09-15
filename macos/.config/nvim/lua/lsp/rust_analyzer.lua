-- Rust Analyzer Language Server configuration
return {
  -- Command to start the language server
  cmd = { "rust-analyzer" },
  
  -- File types this server will attach to
  filetypes = { "rust" },
  
  -- Root directory markers to detect project root
  root_markers = { 
    "Cargo.toml", 
    "rust-project.json",
    "Cargo.lock",
    ".git" 
  },
  
  -- Single file support
  single_file_support = true,
  
  -- Log level
  log_level = vim.lsp.protocol.MessageType.Warning,
  
  -- Rust-specific settings
  settings = {
    ["rust-analyzer"] = {
      -- Import management
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      
      -- Cargo settings
      cargo = {
        buildScripts = {
          enable = true,
        },
        allFeatures = true,
        loadOutDirsFromCheck = true,
        runBuildScripts = true,
      },
      
      -- Procedural macros
      procMacro = {
        enable = true,
        ignored = {
          ["async-trait"] = { "async_trait" },
          ["napi-derive"] = { "napi" },
          ["async-recursion"] = { "async_recursion" },
        },
      },
      
      -- Code checking
      checkOnSave = {
        command = "clippy",
        extraArgs = { "--no-deps" },
      },
      
      -- Diagnostics
      diagnostics = {
        enable = true,
        experimental = {
          enable = true,
        },
      },
      
      -- Completion settings
      completion = {
        addCallArgumentSnippets = true,
        addCallParenthesis = true,
        postfix = {
          enable = true,
        },
        autoimport = {
          enable = true,
        },
      },
      
      -- Assist (code actions)
      assist = {
        importGranularity = "module",
        importPrefix = "by_self",
      },
      
      -- Lens settings
      lens = {
        enable = true,
      },
      
      -- Hover actions
      hoverActions = {
        enable = true,
      },
      
      -- Inlay hints
      inlayHints = {
        bindingModeHints = {
          enable = false,
        },
        chainingHints = {
          enable = true,
        },
        closingBraceHints = {
          enable = true,
          minLines = 25,
        },
        closureReturnTypeHints = {
          enable = "never",
        },
        lifetimeElisionHints = {
          enable = "never",
          useParameterNames = false,
        },
        maxLength = 25,
        parameterHints = {
          enable = true,
        },
        reborrowHints = {
          enable = "never",
        },
        renderColons = true,
        typeHints = {
          enable = true,
          hideClosureInitialization = false,
          hideNamedConstructor = false,
        },
      },
      
      -- Workspace settings
      workspace = {
        symbol = {
          search = {
            scope = "workspace_and_dependencies",
          },
        },
      },
      
      -- Join lines configuration
      joinLines = {
        joinElseIf = true,
        removeTrailingComma = true,
        unwrapTrivialBlock = true,
      },
      
      -- Semantic tokens
      semanticHighlighting = {
        strings = {
          enable = true,
        },
      },
      
      -- Type information
      typing = {
        autoClosingAngleBrackets = {
          enable = false,
        },
      },
      
      -- Files to exclude from analysis
      files = {
        watcher = "notify",
        excludeDirs = { ".git", "node_modules", "target" },
      },
    },
  },
  
  -- Custom on_attach function
  on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    
    -- Enable inlay hints if available (Neovim 0.10+)
    if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
    
    -- Rust-specific keymaps
    local opts = { buffer = bufnr, silent = true }
    
    -- Add custom Rust keymaps
    vim.keymap.set("n", "<leader>rr", function()
      vim.cmd("!cargo run")
    end, vim.tbl_extend("force", opts, { desc = "Cargo run" }))
    
    vim.keymap.set("n", "<leader>rb", function()
      vim.cmd("!cargo build")
    end, vim.tbl_extend("force", opts, { desc = "Cargo build" }))
    
    vim.keymap.set("n", "<leader>rt", function()
      vim.cmd("!cargo test")
    end, vim.tbl_extend("force", opts, { desc = "Cargo test" }))
    
    vim.keymap.set("n", "<leader>rc", function()
      vim.cmd("!cargo check")
    end, vim.tbl_extend("force", opts, { desc = "Cargo check" }))
    
    vim.keymap.set("n", "<leader>rl", function()
      vim.cmd("!cargo clippy")
    end, vim.tbl_extend("force", opts, { desc = "Cargo clippy" }))
  end,
  
  -- Custom initialization options
  init_options = {
    lspMux = nil,
  },
  
  -- Custom capabilities
  capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
        },
      },
    },
  }),
}