if vim.fn.has("nvim-0.9.0") == 0 then
  vim.api.nvim_echo({
    { "NotMeNvim requires Neovim >= 0.9.0\n", "ErrorMsg" },
    { "Press any key to exit", "MoreMsg" },
  }, true, {})
  vim.fn.getchar()
  vim.cmd([[quit]])
  return {}
end

require("notmenvim.config").init()

return {
  { "folke/lazy.nvim", version = "*" },
  { "amooozk/NotMeNvim", priority = 10000, lazy = false, opts = {}, cond = true, version = "*" },
}
