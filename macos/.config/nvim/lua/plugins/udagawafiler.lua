return {
  {
    dir = "/Users/yoheikugue/Workspace/udagawafiler.nvim",
    name = "udagawafiler",
    config = function()
      require('udagawafiler').setup()
    end,
    keys = {
      { "<leader>uf", ":UdagawaFiler<CR>", desc = "Open UdagawaFiler" },
      { "<leader>ur", ":UdagawaFilerTestRust<CR>", desc = "Test Rust functions" },
    },
  }
}