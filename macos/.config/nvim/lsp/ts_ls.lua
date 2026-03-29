-- TypeScript Language Server configuration

-- mise でインストールされた typescript のパスを動的に解決
local function get_typescript_lib_path()
  local handle = io.popen("mise where npm:typescript 2>/dev/null")
  if handle then
    local path = handle:read("*l")
    handle:close()
    if path and path ~= "" then
      return path .. "/lib/node_modules/typescript/lib"
    end
  end
  return nil
end

local tsserver_path = get_typescript_lib_path()

return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_markers = {
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    ".git",
  },
  single_file_support = true,
  init_options = {
    tsserver = tsserver_path and {
      path = tsserver_path,
    } or nil,
    preferences = {
      disableSuggestions = false,
      quotePreference = "auto",
      includeCompletionsForModuleExports = true,
      includeCompletionsForImportStatements = true,
      includeCompletionsWithSnippetText = true,
      includeAutomaticOptionalChainCompletions = true,
    },
  },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "literal",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = false,
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
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
        showOnAllFunctions = false,
      },
      format = {
        enable = false,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
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
        enable = false,
      },
    },
    completions = {
      completeFunctionCalls = true,
    },
  },
}
