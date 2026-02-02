-- Lua Language Server configuration
return {
  -- Command to start the language server
  cmd = { "lua-language-server" },
  
  -- File types this server will attach to
  filetypes = { "lua" },

  -- Root directory markers to detect project root
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git"
  },
  
  -- Log level
  log_level = vim.lsp.protocol.MessageType.Warning,
  
  -- Lua-specific settings
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.list_extend(vim.split(package.path, ";"), {
          "lua/?.lua",
          "lua/?/init.lua"
        })
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/luv/library",
          "${3rd}/busted/library",
          "${3rd}/luassert/library",
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
      completion = {
        callSnippet = "Replace",
        postfix = ".",
        showWord = "Fallback",
        workspaceWord = true,
      },
      diagnostics = {
        enable = true,
        globals = {
          "vim",
          "describe",
          "it",
          "assert",
          "stub",
          "mock",
          "before_each",
          "after_each",
          "teardown",
          "setup",
        },
        disable = { 
          "missing-fields",
          "no-unknown" 
        },
        -- Don't ask about luv every time
        ignoredFiles = "Enable",
        libraryFiles = "Opened",
        severity = {
          ["unused-local"] = "Information",
          ["unused-vararg"] = "Information",
        },
        unusedLocalExclude = { "_*" },
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
          max_line_length = "120",
        }
      },
      hint = {
        enable = true,
        paramType = true,
        setType = false,
        paramName = "Disable",
        semicolon = "Disable",
        arrayIndex = "Disable",
      },
      -- IntelliSense
      IntelliSense = {
        traceLocalSet = false,
        traceReturn = false,
        traceBeSetted = false,
        traceFieldInject = false,
      },
      -- Window settings
      window = {
        progressBar = true,
        statusBar = true,
      },
      -- Telemetry
      telemetry = {
        enable = false,
      },
    },
  },
  
  -- Custom on_attach function
  on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    
    -- Disable formatting (use stylua or other formatters instead)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    
    -- Enable inlay hints if available (Neovim 0.10+)
    if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
  
  -- Custom handlers
  handlers = {
    -- Reduce noise from workspace diagnostics
    ["$/progress"] = function() end,
  },
}