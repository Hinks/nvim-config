return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local api = require("nvim-tree.api")

    local function edit_or_open()
      local node = api.tree.get_node_under_cursor()
      if node.nodes ~= nil then
        api.node.open.edit()
      else
        api.node.open.edit()
        api.tree.close()
      end
    end

    local function vsplit_preview()
      local node = api.tree.get_node_under_cursor()
      if node.nodes ~= nil then
        api.node.open.edit()
      else
        api.node.open.vertical()
      end
      api.tree.focus()
    end

    require("nvim-tree").setup {
      open_on_setup = false,
      open_on_setup_file = false,
      on_attach = function(bufnr)
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        vim.keymap.set("n", "l", edit_or_open, opts("Edit Or Open"))
        vim.keymap.set("n", "L", vsplit_preview, opts("Vsplit Preview"))
        vim.keymap.set("n", "h", api.tree.close, opts("Close"))
        vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
      end,
    }

    -- Global: toggle tree with <C-h>
    vim.keymap.set("n", "<C-h>", ":NvimTreeToggle<cr>", { silent = true, noremap = true, desc = "NvimTree Toggle" })

    -- Automatically find file in tree when switching buffers
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        if vim.bo.filetype == "NvimTree" then
          return
        end
        if api.tree.is_visible() then
          api.tree.find_file({ focus = false, open = true })
        end
      end,
    })
  end,
}
