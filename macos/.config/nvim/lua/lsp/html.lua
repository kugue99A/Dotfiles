-- HTML Language Server configuration
return {
  -- Command to start the language server
  cmd = { "vscode-html-language-server", "--stdio" },
  
  -- File types this server will attach to
  filetypes = { 
    "html", 
    "templ" 
  },
  
  -- Root directory markers to detect project root
  root_markers = { 
    "package.json", 
    ".git", 
    "index.html" 
  },
  
  -- Single file support
  single_file_support = true,
  
  -- Initialization options
  init_options = {
    provideFormatter = true,
    embeddedLanguages = {
      css = true,
      javascript = true,
    },
    configurationSection = { "html", "css", "javascript" },
  },
  
  -- HTML-specific settings
  settings = {
    html = {
      format = {
        templating = true,
        wrapLineLength = 120,
        wrapAttributes = "auto",
      },
      hover = {
        documentation = true,
        references = true,
      },
    },
  },
  
  -- Custom on_attach function
  on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    
    -- Format on save if formatter is available
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {}),
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
        end,
      })
    end
  end,
}