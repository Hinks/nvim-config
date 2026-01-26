vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")


vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d")

-- search
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- format
vim.keymap.set("n", "<leader>F", vim.lsp.buf.format, { desc = "Format with LSP" })

-- Omni autocomplete meny Ctrl-o go next menu item
vim.keymap.set("i", "<C-o>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<C-o>"
end, { expr = true, silent = true })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "elm",
    callback = function()
        --vim.opt_local.colorcolumn = "80"

        -- Override visual-mode J/K only for Elm
        --Fixes the unwanted injection in elm files
        vim.keymap.set("v", "J", ":m '>+1<CR>gv", { buffer = true })
        vim.keymap.set("v", "K", ":m '<-2<CR>gv", { buffer = true })
    end,
})

-- auto-reload files when modified externally
-- https://unix.stackexchange.com/a/383044
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { "*" },
})

-- Use CTRL-space to trigger LSP completion.
-- Use CTRL-Y to select an item. |complete_CTRL-Y|
vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { desc = 'Trigger LSP completion' })

