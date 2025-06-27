return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("lspconfig").elmls.setup {}
        end,
    }
}