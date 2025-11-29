return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {}
      
      -- Automatically find file in tree when switching buffers
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          local api = require("nvim-tree.api")
          -- Don't trigger when in nvim-tree buffer itself
          if vim.bo.filetype == "NvimTree" then
            return
          end
          -- Only update if nvim-tree is open
          if api.tree.is_visible() then
            api.tree.find_file({ focus = false, open = true })
          end
        end,
      })
    end,
  }