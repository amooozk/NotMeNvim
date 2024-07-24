return {
  recommended = function()
    return NotMeNvim.extras.wants({
      ft = "toml",
      root = "*.toml",
    })
  end,
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      taplo = {},
    },
  },
}
