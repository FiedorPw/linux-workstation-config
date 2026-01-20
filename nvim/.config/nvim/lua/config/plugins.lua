return {
  -- 🌈 Nordic colorscheme
  {
    "AlexvZyl/nordic.nvim",
    priority = 1000,
    config = function()
      require("nordic").load()
    end,
  },

  -- 🌳 Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },

  -- ⌨️ which-key
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },

  -- 💬 Comment.nvim
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- │ Indent Blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- 💅 Noice (with dependencies)
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup()
    end,
  },

  -- 🎨 Colorizer
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },

-- 📁 nvim-tree (file explorer)
{
"nvim-tree/nvim-tree.lua",
dependencies = { "nvim-tree/nvim-web-devicons" },
config = function()
  require("nvim-tree").setup()
  -- Optional: open tree with leader + e
  vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
end,
},

-- 📊 lualine (statusline)
{
"nvim-lualine/lualine.nvim",
dependencies = { "nvim-tree/nvim-web-devicons" },
config = function()
  require("lualine").setup {
    options = {
      theme = "nordic",
      section_separators = "",
      component_separators = "",
    },
  }
end,
},

{
  "numirias/semshi",
  ft = "python", -- only loads on Python files
  build = ":UpdateRemotePlugins",
  init = function()
    vim.g["semshi#error_sign"] = false
    vim.g["semshi#mark_selected_nodes"] = true
    vim.g["semshi#update_delay_factor"] = 0.1
  end,
},
}
