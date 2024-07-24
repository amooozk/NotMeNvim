-- start screen
return {
  -- disable alpha
  { "goolord/alpha-nvim", enabled = false },
  { "nvimdev/dashboard-nvim", enabled = false },

  -- enable mini.starter
  {
    "echasnovski/mini.starter",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = "VimEnter",
    opts = function()
      local logo = table.concat({
        "███╗   ██╗ ██████╗ ████████╗███╗   ███╗███████╗███╗   ██╗██╗   ██╗██╗███╗   ███╗",
        "████╗  ██║██╔═══██╗╚══██╔══╝████╗ ████║██╔════╝████╗  ██║██║   ██║██║████╗ ████║",
        "██╔██╗ ██║██║   ██║   ██║   ██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║██║██╔████╔██║",
        "██║╚██╗██║██║   ██║   ██║   ██║╚██╔╝██║██╔══╝  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "██║ ╚████║╚██████╔╝   ██║   ██║ ╚═╝ ██║███████╗██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
      }, "\n")
      local pad = string.rep(" ", 22)
      local new_section = function(name, action, section)
        return { name = name, action = action, section = pad .. section }
      end

      local starter = require("mini.starter")
      --stylua: ignore
      local config = {
        evaluate_single = true,
        header = logo,
        items = {
          new_section("Find file",       NotMeNvim.pick(),                        "Telescope"),
          new_section("New file",        "ene | startinsert",                   "Built-in"),
          new_section("Recent files",    NotMeNvim.pick("oldfiles"),              "Telescope"),
          new_section("Config",          NotMeNvim.pick.config_files(),           "Config"),
          new_section("Previous session", [[lua require("persistence").load()]], "Session"),
          new_section("Quit",            "qa",                                  "Built-in"),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(pad .. " ", false),
          starter.gen_hook.aligning("center", "center"),
        },
      }
      return config
    end,
    config = function(_, config)
      -- close Lazy and re-open when starter is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "MiniStarterOpened",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      local starter = require("mini.starter")
      starter.setup(config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "NotMeNvimStarted",
        callback = function(ev)
          local pad_footer = string.rep(" ", 8)
          starter.config.footer = pad_footer
            .. " Changing the Config without NotMe's permission on NotMe's Machine is strictly prohibited "
          if vim.bo[ev.buf].filetype == "ministarter" then
            pcall(starter.refresh)
          end
        end,
      })
    end,
  },
}
