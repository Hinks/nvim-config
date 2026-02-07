return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.lsp.enable('elmls')
            vim.lsp.enable('ts_ls')

            vim.diagnostic.config({ virtual_lines = true })

            vim.keymap.set('n', 'gK', function()
                local new_config = not vim.diagnostic.config().virtual_lines
                vim.diagnostic.config({ virtual_lines = new_config })
            end, { desc = 'Toggle diagnostic virtual_lines' })

            vim.keymap.set('n', '<leader>lr', '<cmd>LspRestart<CR>', { desc = 'Restart LSP' })
        end,
    }
}
