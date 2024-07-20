return {
  'williamboman/mason-lspconfig.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('mason-lspconfig').setup_handlers({ function(server)
      local opt = {
        capabilities = require('cmp_nvim_lsp').default_capabilities(
          vim.lsp.protocol.make_client_capabilities()
        )
      }
      require('lspconfig')[server].setup(opt)
    end })
  end
}