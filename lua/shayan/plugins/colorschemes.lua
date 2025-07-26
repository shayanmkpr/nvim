return{
--   "folke/tokyonight.nvim",
--   priority = 1000,
--   config = function()
--     require("tokyonight").setup({
--       style = "night",
--       -- make comments italic
--       styles = {
--         comments = { italic = true },
--         keywords = { italic = true },
--         functions = { italic = true },
--       },
--       transparent = false
--     })
--
--     vim.cmd("colorscheme tokyonight")
--   end,
--

 "EdenEast/nightfox.nvim",
  config = function()
    require("nightfox").setup({
      style = "nightfox",
      options = {
      transparent = true
      }
    })
    vim.cmd("colorscheme nightfox")
  end

 -- "rose-pine/neovim",
 --  config = function()
 --    require("rose-pine").setup({
 --      styles = {
 --        transparency = true,
 --        italic = true,
 --        bold = true
 --        }
 --          })
 --    vim.cmd("colorscheme rose-pine-moon")
 --  end

  -- "catppuccin/nvim",
  -- name = "catppuccin",
  -- priority = 1000,
  -- config = function()
  -- require("catppuccin").setup({
  --   flavour = "macchiato",
  --   transparent_background = true,
  --   styles = {
  --       keywords = {"italic", "bold"},
  --       strings  = {"italic"},
  --       comments = {"italic", "bold"},
  --       numbers = {"bold"}
  --     }
  -- })
  -- vim.cmd("colorscheme catppuccin")
  -- end
}
