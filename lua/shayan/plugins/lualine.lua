return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  config = function()
    local function recording_status()
      local reg = vim.fn.reg_recording()
      if reg == "" then return "" end
      return "@" .. reg
    end
    local function search_count()
      local sc = vim.fn.searchcount()
      if sc.total == 0 then
        return ""
      end
      return "[" .. sc.current .. "/" .. sc.total .. "]"
    end
    local function penguin()
      return "󰻀Ψ" or "󰻀Ψ"
    end

    require("lualine").setup({
      sections = {
        lualine_x = {
        },
        lualine_y = {
          recording_status,
          search_count,
        },
        lualine_z = {
          penguin,
        },
      },

    })
  end
}

