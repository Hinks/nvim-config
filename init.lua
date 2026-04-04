-- Basics {{{
vim.g.mapleader = " "

-- Disable netrw and its plugin loader.
-- These globals use `1` as a "loaded already" flag, which prevents Neovim from loading netrw.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- vim.g.netrw_banner = 0          -- disable annoying banner
-- vim.g.netrw_winsize = 25
-- vim.g.netrw_browse_split = 0
-- vim.g.netrw_altv = 1            -- open splits to the right
-- vim.g.netrw_liststyle = 3       -- tree view
-- }}}

-- Options {{{
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Case-insensitive command-line Tab completion (e.g. :nvimt<Tab> matches NvimTreeToggle).
-- wildignorecase = file/dir completion only; ignorecase = command names and other completions.
vim.opt.ignorecase = true
vim.opt.smartcase = true -- override: search case-sensitive when pattern has uppercase
vim.opt.wildignorecase = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.o.laststatus = 3

-- vim.opt.colorcolumn = "80"
vim.o.autoread = true
-- }}}

-- Plugin hooks {{{
local pack_hooks_group = vim.api.nvim_create_augroup("UserPackHooks", { clear = true })

-- Build telescope-fzf-native after install/update so Telescope can load the native sorter.
vim.api.nvim_create_autocmd("PackChanged", {
  group = pack_hooks_group,
  callback = function(ev)
    local spec = ev.data and ev.data.spec or nil
    local kind = ev.data and ev.data.kind or nil

    if not spec or spec.name ~= "telescope-fzf-native.nvim" then
      return
    end

    if kind ~= "install" and kind ~= "update" then
      return
    end

    local plugin_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt", spec.name)
    local result = vim.system({ "make" }, { cwd = plugin_dir, text = true }):wait()

    if result.code ~= 0 then
      vim.notify(
        "Failed to build telescope-fzf-native.nvim:\n" .. (result.stderr ~= "" and result.stderr or "make exited with a non-zero status"),
        vim.log.levels.ERROR
      )
    end
  end,
})
-- }}}

-- Plugins {{{
vim.pack.add({
  "https://github.com/folke/tokyonight.nvim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-tree/nvim-web-devicons",
  { src = "https://github.com/nvim-tree/nvim-tree.lua", version = vim.version.range("*") },
  "https://github.com/nvim-lua/plenary.nvim",
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", version = "main" },
  { src = "https://github.com/nvim-telescope/telescope.nvim", version = "master" },
  "https://github.com/rafamadriz/friendly-snippets",
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.x") },
  { src = "https://github.com/nvim-mini/mini.pairs", version = vim.version.range("*") },
  { src = "https://github.com/nvim-mini/mini.surround", version = vim.version.range("*") },
})
-- }}}

-- Colorscheme: tokyonight {{{
require("tokyonight").setup({
  style = "storm",
  transparent = true,
  terminal_colors = true,
  styles = {
    comments = { italic = false },
    keywords = { italic = false },
    sidebars = "dark",
    floats = "dark",
  },
})

vim.cmd.colorscheme("tokyonight-storm")
-- }}}

-- Autocommands {{{
-- auto-reload files when modified externally
-- https://unix.stackexchange.com/a/383044
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  pattern = { "*" },
  command = "if mode() != 'c' | checktime | endif",
})
-- }}}

-- Keymaps {{{
-- Toggle the file tree.
vim.keymap.set("n", "<leader>pv", "<cmd>NvimTreeToggle<CR>", { desc = "NvimTree Toggle" })

-- Move the selected block up/down and keep it selected so repeated moves are easy.
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Join the next line without moving the cursor from its current spot.
vim.keymap.set("n", "J", "mzJ`z")
-- Keep the cursor centered while paging through the file.
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- Keep search results centered as you jump between matches.
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Replace the selection with the default register while preserving the last yanked text.
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Yank directly to the system clipboard.
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
-- Delete without overwriting the unnamed register.
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d")

-- search
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- format
vim.keymap.set("n", "<leader>F", vim.lsp.buf.format, { desc = "Format with LSP" })

-- Alternatively, save with <Leader>fs (File Save)
vim.keymap.set("n", "<Leader>fs", ":update<CR>", { desc = "Save File" })
-- }}}

-- Nvim-tree {{{
local nvim_tree_group = vim.api.nvim_create_augroup("UserNvimTree", { clear = true })
local nvim_tree_api = require("nvim-tree.api")

local function nvim_tree_edit_or_open()
  local node = nvim_tree_api.tree.get_node_under_cursor()

  if node.nodes ~= nil then
    nvim_tree_api.node.open.edit()
  else
    nvim_tree_api.node.open.edit()
    nvim_tree_api.tree.close()
  end
end

local function nvim_tree_vsplit_preview()
  local node = nvim_tree_api.tree.get_node_under_cursor()

  if node.nodes ~= nil then
    nvim_tree_api.node.open.edit()
  else
    nvim_tree_api.node.open.vertical()
  end

  nvim_tree_api.tree.focus()
end

require("nvim-tree").setup({
  on_attach = function(bufnr)
    local function opts(desc)
      return {
        desc = "nvim-tree: " .. desc,
        buffer = bufnr,
        noremap = true,
        silent = true,
        nowait = true,
      }
    end

    nvim_tree_api.config.mappings.default_on_attach(bufnr)
    vim.keymap.set("n", "l", nvim_tree_edit_or_open, opts("Edit Or Open"))
    vim.keymap.set("n", "L", nvim_tree_vsplit_preview, opts("Vsplit Preview"))
    vim.keymap.set("n", "h", nvim_tree_api.tree.close, opts("Close"))
    vim.keymap.set("n", "H", nvim_tree_api.tree.collapse_all, opts("Collapse All"))
  end,
})

-- Keep the tree synced to the current buffer when it is open.
vim.api.nvim_create_autocmd("BufEnter", {
  group = nvim_tree_group,
  callback = function()
    if vim.bo.filetype == "NvimTree" then
      return
    end

    if nvim_tree_api.tree.is_visible() then
      nvim_tree_api.tree.find_file({ focus = false, open = true })
    end
  end,
})
-- }}}

-- Telescope {{{
require("telescope").setup({
  defaults = {
    file_ignore_patterns = {
      "^node_modules/",
      "^elmstuff/",
      "^dist/",
      "%.git/",
      "%.cache/",
      "%.next/",
      "%.venv/",
      "__pycache__/",
      "%.DS_Store",
    },
  },
  pickers = {
    find_files = {
      theme = "ivy",
    },
  },
  extensions = {
    fzf = {},
  },
})

require("telescope").load_extension("fzf")

local telescope_builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", telescope_builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", telescope_builtin.help_tags, { desc = "Telescope help tags" })

vim.keymap.set("n", "<leader>en", function()
  telescope_builtin.find_files({
    cwd = vim.fn.stdpath("config"),
  })
end, { desc = "Find Neovim config files" })

vim.keymap.set("n", "<leader>ep", function()
  telescope_builtin.find_files({
    cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt"),
  })
end, { desc = "Find vim.pack plugin files" })
-- }}}

-- Tree-sitter {{{
local treesitter_group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })
local treesitter_parsers = {
  "python",
  "lua",
  "markdown",
  "javascript",
  "elm",
  "typescript",
}

-- Keep parsers in sync when the plugin itself is installed or updated.
vim.api.nvim_create_autocmd("PackChanged", {
  group = treesitter_group,
  callback = function(ev)
    local spec = ev.data and ev.data.spec or nil
    local kind = ev.data and ev.data.kind or nil

    if not spec or spec.name ~= "nvim-treesitter" then
      return
    end

    if kind ~= "install" and kind ~= "update" then
      return
    end

    if not ev.data.active then
      vim.cmd.packadd("nvim-treesitter")
    end

    vim.cmd("TSUpdate")
  end,
})

-- nvim-treesitter should load at startup, and setup() is optional unless you need custom install_dir.

-- Install the parsers this config expects. This is a no-op when they are already present.
require("nvim-treesitter").install(treesitter_parsers)

-- Start Tree-sitter highlighting automatically and enable Tree-sitter indentation where it behaves well.
vim.api.nvim_create_autocmd("FileType", {
  group = treesitter_group,
  desc = "User: enable treesitter highlighting",
  callback = function(ctx)
    local has_started = pcall(vim.treesitter.start)
    local no_indent = { "elm", "typescript" }

    if has_started and not vim.list_contains(no_indent, ctx.match) then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
-- }}}

-- LSP {{{
-- Enable the language servers you currently use.
vim.lsp.enable("elmls")
vim.lsp.enable("ts_ls")

-- Show diagnostics inline as virtual lines by default.
vim.diagnostic.config({ virtual_lines = true })

-- Toggle inline diagnostics without reopening Neovim.
vim.keymap.set("n", "gK", function()
  local new_config = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = new_config })
end, { desc = "Toggle diagnostic virtual_lines" })

vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "Restart LSP" })
-- }}}

-- Completion {{{
require("blink.cmp").setup({
  keymap = { preset = "default" },
  signature = { enabled = true },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = {
    documentation = { auto_show = false },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = {
    implementation = "prefer_rust_with_warning",
  },
})
-- }}}

-- Mini surround {{{
require("mini.surround").setup()
-- }}}

-- Mini pairs {{{
require("mini.pairs").setup()
-- }}}