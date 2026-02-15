-- Lua Language Server configuration
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  },
  single_file_support = true,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.list_extend(vim.split(package.path, ";"), {
          "lua/?.lua",
          "lua/?/init.lua",
        }),
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
          "no-unknown",
        },
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
        },
      },
      hint = {
        enable = true,
        paramType = true,
        setType = false,
        paramName = "Disable",
        semicolon = "Disable",
        arrayIndex = "Disable",
      },
      IntelliSense = {
        traceLocalSet = false,
        traceReturn = false,
        traceBeSetted = false,
        traceFieldInject = false,
      },
      window = {
        progressBar = true,
        statusBar = true,
      },
      telemetry = {
        enable = false,
      },
    },
  },
  handlers = {
    -- Reduce noise from workspace diagnostics
    ["$/progress"] = function() end,
  },
}
