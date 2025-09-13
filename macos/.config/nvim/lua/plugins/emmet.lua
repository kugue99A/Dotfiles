-- Emmet support for HTML/JSX/CSS abbreviations
return {
  "mattn/emmet-vim",
  ft = { 
    "html", 
    "css", 
    "javascript", 
    "javascriptreact", 
    "typescript", 
    "typescriptreact", 
    "vue", 
    "svelte" 
  },
  config = function()
    -- Set leader key for Emmet (default is <C-y>)
    vim.g.user_emmet_leader_key = '<C-y>'
    
    -- Enable Emmet for specific file types
    vim.g.user_emmet_settings = {
      javascript = {
        extends = 'jsx',
      },
      typescript = {
        extends = 'jsx',
      },
      ['javascript.jsx'] = {
        extends = 'jsx',
      },
      ['typescript.tsx'] = {
        extends = 'jsx',
      },
    }
    
    -- Auto enable for supported file types
    vim.g.user_emmet_install_global = 0
    
    -- Enable Emmet for specific file types
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { 
        "html", 
        "css", 
        "javascript", 
        "javascriptreact", 
        "typescript", 
        "typescriptreact", 
        "vue", 
        "svelte" 
      },
      callback = function()
        vim.cmd("EmmetInstall")
      end,
    })
  end,
}