---@class notmenvim.util.news
local M = {}

function M.hash(file)
  local stat = vim.uv.fs_stat(file)
  if not stat then
    return
  end
  return stat.size .. ""
end

function M.setup()
  vim.schedule(function()
    if NotMeNvim.config.news.notmenvim then
      if not NotMeNvim.config.json.data.news["NEWS.md"] then
        M.welcome()
      end
      M.notmenvim(true)
    end
    if NotMeNvim.config.news.neovim then
      M.neovim(true)
    end
  end)
end

function M.welcome()
  NotMeNvim.info("NotMeNvim: Aye Yooo!! O__o")
end

function M.changelog()
  M.open("CHANGELOG.md", { plugin = "NotMeNvim" })
end

function M.notmenvim(when_changed)
  M.open("NEWS.md", { plugin = "NotMeNvim", when_changed = when_changed })
end

function M.neovim(when_changed)
  M.open("doc/news.txt", { rtp = true, when_changed = when_changed })
end

---@param file string
---@param opts? {plugin?:string, rtp?:boolean, when_changed?:boolean}
function M.open(file, opts)
  local ref = file
  opts = opts or {}
  if opts.plugin then
    local plugin = require("lazy.core.config").plugins[opts.plugin] --[[@as LazyPlugin?]]
    if not plugin then
      return NotMeNvim.error("plugin not found: " .. opts.plugin)
    end
    file = plugin.dir .. "/" .. file
  elseif opts.rtp then
    file = vim.api.nvim_get_runtime_file(file, false)[1]
  end

  if not file then
    return NotMeNvim.error("File not found")
  end

  if opts.when_changed then
    local is_new = not NotMeNvim.config.json.data.news[ref]
    local hash = M.hash(file)
    if hash == NotMeNvim.config.json.data.news[ref] then
      return
    end
    NotMeNvim.config.json.data.news[ref] = hash
    NotMeNvim.json.save()
    -- don't open if file has never been opened
    if is_new then
      return
    end
  end

  local float = require("lazy.util").float({
    file = file,
    size = { width = 0.6, height = 0.6 },
  })
  vim.opt_local.spell = false
  vim.opt_local.wrap = false
  vim.opt_local.signcolumn = "yes"
  vim.opt_local.statuscolumn = " "
  vim.opt_local.conceallevel = 3
  vim.diagnostic.disable(float.buf)
end

return M
