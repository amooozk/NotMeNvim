return {
  recommended = function()
    return NotMeNvim.extras.wants({
      ft = "astro",
      root = {
        -- https://docs.astro.build/en/guides/configuring-astro/#supported-config-file-types
        "astro.config.js",
        "astro.config.mjs",
        "astro.config.cjs",
        "astro.config.ts",
      },
    })
  end,

  -- depends on the typescript extra
  { import = "notmenvim.plugins.extras.lang.typescript" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "astro" } },
  },

  -- LSP Servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        astro = {},
      },
    },
  },

  -- Configure tsserver plugin
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      NotMeNvim.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
        {
          name = "@astrojs/ts-plugin",
          location = NotMeNvim.get_pkg_path("astro-language-server", "/node_modules/@astrojs/ts-plugin"),
          enableForWorkspaceTypeScriptVersions = true,
        },
      })
    end,
  },

  {
    "conform.nvim",
    opts = function(_, opts)
      if NotMeNvim.has_extra("formatting.prettier") then
        opts.formatters_by_ft = opts.formatters_by_ft or {}
        opts.formatters_by_ft.astro = { "prettier" }
      end
    end,
  },
}
