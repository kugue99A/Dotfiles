return {
  event = { 'BufReadPre', 'BufNewFile' },
  'williamboman/mason.nvim',
  config = function()
    require('mason').setup()
  end
}