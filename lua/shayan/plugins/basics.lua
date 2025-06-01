return{
  { "nvim-lua/plenary.nvim" },
  -- Telescope
  { "nvim-telescope/telescope.nvim", tag = "0.1.4" },
  -- Codeium
  { 'Exafunction/codeium.vim', event = 'BufEnter' },
  -- Outline
--   {
--     "simrat39/symbols-outline.nvim",
--   config = function()
--   vim.keymap.set("n", "<leader>o", "<cmd>SymbolsOutline<CR>",
--         { desc = "Toggle Outline" })
--
--     require('symbols-outline').setup()
--   end;
--   },
}
