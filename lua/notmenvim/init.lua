vim.uv = vim.uv or vim.loop

local M = {}

---@param opts? NotMeNvimConfig
function M.setup(opts)
  require("notmenvim.config").setup(opts)
end

return M
