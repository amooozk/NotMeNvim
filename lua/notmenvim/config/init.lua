_G.NotMeNvim = require("notmenvim.util")

---@class NotMeNvimConfig: NotMeNvimOptions
local M = {}

M.version = "12.34.0" -- x-release-please-version
NotMeNvim.config = M

---@class NotMeNvimOptions
local defaults = {
  ---@type string|fun()
  colorscheme = function()
    require("tokyonight").load() -- the default colorscheme
  end,
  -- load the default settings
  defaults = {
    autocmds = true, -- notmenvim.config.autocmds
    keymaps = true, -- notmenvim.config.keymaps
    -- notmenvim.config.options can't be configured here since that's loaded before notmenvim setup
    -- if you want to disable loading options, add `package.loaded["notmenvim.config.options"] = true` to the top of your init.lua
  },
  news = {
    -- When enabled, NEWS.md will be shown when changed.
    -- This only contains big new features and breaking changes.
    notmenvim = true,
    -- Same but for Neovim's news.txt
    neovim = false,
  },
  -- icons used by other plugins
  -- stylua: ignore
  icons = {
    misc = {
      dots = "󰇘",
    },
    ft = {
      octo = "",
    },
    dap = {
      Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint          = " ",
      BreakpointCondition = " ",
      BreakpointRejected  = { " ", "DiagnosticError" },
      LogPoint            = ".>",
    },
    diagnostics = {
      Error = " ",
      Warn  = " ",
      Hint  = " ",
      Info  = " ",
    },
    git = {
      added    = " ",
      modified = " ",
      removed  = " ",
    },
    kinds = {
      Array         = " ",
      Boolean       = "󰨙 ",
      Class         = " ",
      Codeium       = "󰘦 ",
      Color         = " ",
      Control       = " ",
      Collapsed     = " ",
      Constant      = "󰏿 ",
      Constructor   = " ",
      Copilot       = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = " ",
      Field         = " ",
      File          = " ",
      Folder        = " ",
      Function      = "󰊕 ",
      Interface     = " ",
      Key           = " ",
      Keyword       = " ",
      Method        = "󰊕 ",
      Module        = " ",
      Namespace     = "󰦮 ",
      Null          = " ",
      Number        = "󰎠 ",
      Object        = " ",
      Operator      = " ",
      Package       = " ",
      Property      = " ",
      Reference     = " ",
      Snippet       = " ",
      String        = " ",
      Struct        = "󰆼 ",
      TabNine       = "󰏚 ",
      Text          = " ",
      TypeParameter = " ",
      Unit          = " ",
      Value         = " ",
      Variable      = "󰀫 ",
    },
  },
  ---@type table<string, string[]|boolean>?
  kind_filter = {
    default = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Package",
      "Property",
      "Struct",
      "Trait",
    },
    markdown = false,
    help = false,
    -- you can specify a different filter for each filetype
    lua = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      -- "Package", -- remove package since luals uses it for control flow structures
      "Property",
      "Struct",
      "Trait",
    },
  },
}

M.json = {
  version = 6,
  path = vim.g.notmenvim_json or vim.fn.stdpath("config") .. "/notmenvim.json",
  data = {
    version = nil, ---@type string?
    news = {}, ---@type table<string, string>
    extras = {}, ---@type string[]
  },
}

function M.json.load()
  local f = io.open(M.json.path, "r")
  if f then
    local data = f:read("*a")
    f:close()
    local ok, json = pcall(vim.json.decode, data, { luanil = { object = true, array = true } })
    if ok then
      M.json.data = vim.tbl_deep_extend("force", M.json.data, json or {})
      if M.json.data.version ~= M.json.version then
        NotMeNvim.json.migrate()
      end
    end
  end
end

---@type NotMeNvimOptions
local options
local lazy_clipboard

---@param opts? NotMeNvimOptions
function M.setup(opts)
  options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

  -- autocmds can be loaded lazily when not opening a file
  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then
    M.load("autocmds")
  end

  local group = vim.api.nvim_create_augroup("NotMeNvim", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      if lazy_autocmds then
        M.load("autocmds")
      end
      M.load("keymaps")
      if lazy_clipboard ~= nil then
        vim.opt.clipboard = lazy_clipboard
      end

      NotMeNvim.format.setup()
      NotMeNvim.news.setup()
      NotMeNvim.root.setup()

      vim.api.nvim_create_user_command("LazyExtras", function()
        NotMeNvim.extras.show()
      end, { desc = "Manage NotMeNvim extras" })

      vim.api.nvim_create_user_command("LazyHealth", function()
        vim.cmd([[Lazy! load all]])
        vim.cmd([[checkhealth]])
      end, { desc = "Load all plugins and run :checkhealth" })

      local health = require("lazy.health")
      vim.list_extend(health.valid, {
        "recommended",
        "desc",
        "vscode",
      })
    end,
  })

  NotMeNvim.track("colorscheme")
  NotMeNvim.try(function()
    if type(M.colorscheme) == "function" then
      M.colorscheme()
    else
      vim.cmd.colorscheme(M.colorscheme)
    end
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      NotMeNvim.error(msg)
      vim.cmd.colorscheme("habamax")
    end,
  })
  NotMeNvim.track()
end

---@param buf? number
---@return string[]?
function M.get_kind_filter(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local ft = vim.bo[buf].filetype
  if M.kind_filter == false then
    return
  end
  if M.kind_filter[ft] == false then
    return
  end
  if type(M.kind_filter[ft]) == "table" then
    return M.kind_filter[ft]
  end
  ---@diagnostic disable-next-line: return-type-mismatch
  return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
  local function _load(mod)
    if require("lazy.core.cache").find(mod)[1] then
      NotMeNvim.try(function()
        require(mod)
      end, { msg = "Failed loading " .. mod })
    end
  end
  local pattern = "NotMeNvim" .. name:sub(1, 1):upper() .. name:sub(2)
  -- always load notmenvim, then user file
  if M.defaults[name] or name == "options" then
    _load("notmenvim.config." .. name)
    vim.api.nvim_exec_autocmds("User", { pattern = pattern .. "Defaults", modeline = false })
  end
  _load("config." .. name)
  if vim.bo.filetype == "lazy" then
    -- HACK: NotMeNvim may have overwritten options of the Lazy ui, so reset this here
    vim.cmd([[do VimResized]])
  end
  vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

M.did_init = false
function M.init()
  if M.did_init then
    return
  end
  M.did_init = true
  local plugin = require("lazy.core.config").spec.plugins.NotMeNvim
  if plugin then
    vim.opt.rtp:append(plugin.dir)
  end

  package.preload["notmenvim.plugins.lsp.format"] = function()
    NotMeNvim.deprecate([[require("notmenvim.plugins.lsp.format")]], [[NotMeNvim.format]])
    return NotMeNvim.format
  end

  -- delay notifications till vim.notify was replaced or after 500ms
  NotMeNvim.lazy_notify()

  -- load options here, before lazy init while sourcing plugin modules
  -- this is needed to make sure options will be correctly applied
  -- after installing missing plugins
  M.load("options")
  -- defer built-in clipboard handling: "xsel" and "pbcopy" can be slow
  lazy_clipboard = vim.opt.clipboard
  vim.opt.clipboard = ""

  if vim.g.deprecation_warnings == false then
    vim.deprecate = function() end
  end

  NotMeNvim.plugin.setup()
  M.json.load()
end

setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    ---@cast options NotMeNvimConfig
    return options[key]
  end,
})

return M
