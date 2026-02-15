-- Rust Analyzer Language Server configuration
return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = {
    "Cargo.toml",
    "rust-project.json",
    "Cargo.lock",
    ".git",
  },
  single_file_support = true,
  log_level = vim.lsp.protocol.MessageType.Warning,
  settings = {
    ["rust-analyzer"] = {
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
        allFeatures = true,
        loadOutDirsFromCheck = true,
        runBuildScripts = true,
      },
      procMacro = {
        enable = true,
        ignored = {
          ["async-trait"] = { "async_trait" },
          ["napi-derive"] = { "napi" },
          ["async-recursion"] = { "async_recursion" },
        },
      },
      check = {
        command = "clippy",
        extraArgs = { "--no-deps" },
      },
      diagnostics = {
        enable = true,
        experimental = {
          enable = true,
        },
      },
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
      assist = {
        importGranularity = "module",
        importPrefix = "by_self",
      },
      lens = {
        enable = true,
      },
      hoverActions = {
        enable = true,
      },
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
      workspace = {
        symbol = {
          search = {
            scope = "workspace_and_dependencies",
          },
        },
      },
      joinLines = {
        joinElseIf = true,
        removeTrailingComma = true,
        unwrapTrivialBlock = true,
      },
      semanticHighlighting = {
        strings = {
          enable = true,
        },
      },
      typing = {
        autoClosingAngleBrackets = {
          enable = false,
        },
      },
      files = {
        watcher = "notify",
        excludeDirs = { ".git", "node_modules", "target" },
      },
    },
  },
}
