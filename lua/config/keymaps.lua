-- Leader 键设置（必须在 lazy.nvim 加载前设置）
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap

-- 按 Esc 清除搜索高亮
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "清除搜索高亮" })

-- 快速打开 Lazy 插件管理面板
keymap.set("n", "<leader>l", "<cmd>Lazy<CR>", { desc = "打开 Lazy 插件管理器" })
