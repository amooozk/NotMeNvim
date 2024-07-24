return {
  recommended = function()
    return NotMeNvim.extras.wants({
      ft = { "erlang" },
      root = { "rebar.config", "erlang.mk" },
    })
  end,
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        erlangls = {},
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "erlang" } },
  },
}
