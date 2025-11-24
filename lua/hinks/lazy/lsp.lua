return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.lsp.enable('elmls')
            --require("lspconfig").elmls.setup {}
        end,
    }
}
