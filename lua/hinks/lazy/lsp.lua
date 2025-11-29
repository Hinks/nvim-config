return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.lsp.enable('elmls')
            vim.lsp.enable('ts_ls')
        end,
    }
}
