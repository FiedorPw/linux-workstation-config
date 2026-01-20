local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- File explorer (Telescope)
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opts)
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts)
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opts)

-- Clipboard
map("v", "<C-c>", '"+y', opts)
map("n", "<C-v>", '"+p', opts)
map("i", "<C-v>", '<C-r>+', opts)
