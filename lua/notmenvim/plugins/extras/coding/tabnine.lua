return {
  -- Tabnine cmp source
  {
    "nvim-cmp",
    dependencies = {
      {
        "tzachar/cmp-tabnine",
        build = {
          NotMeNvim.is_win() and "pwsh -noni .\\install.ps1" or "./install.sh",
          ":CmpTabnineHub",
        },
        dependencies = "hrsh7th/nvim-cmp",
        opts = {
          max_lines = 1000,
          max_num_results = 3,
          sort = true,
        },
        config = function(_, opts)
          require("cmp_tabnine.config"):setup(opts)
        end,
      },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "cmp_tabnine",
        group_index = 1,
        priority = 100,
      })

      opts.formatting.format = NotMeNvim.inject.args(opts.formatting.format, function(entry, item)
        -- Hide percentage in the menu
        if entry.source.name == "cmp_tabnine" then
          item.menu = ""
        end
      end)
    end,
  },
  -- Show TabNine status in lualine
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      local icon = NotMeNvim.config.icons.kinds.TabNine
      table.insert(opts.sections.lualine_x, 2, NotMeNvim.lualine.cmp_source("cmp_tabnine", icon))
    end,
  },
}
