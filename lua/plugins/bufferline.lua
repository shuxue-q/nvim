return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "thin",
        -- 左侧打开 neo-tree 时自动让出对齐标题区域
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
            separator = true,
          },
        },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)

      local keymap = vim.keymap

      -- Ctrl+h / Ctrl+l 左右切换顶部标签页
      keymap.set("n", "<C-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "切换到左侧标签页" })
      keymap.set("n", "<C-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "切换到右侧标签页" })

      -- 关闭当前标签页（保持左侧文件树分屏布局不塌陷）
      keymap.set("n", "<leader>bd", function()
        local cur = vim.api.nvim_get_current_buf()
        if vim.bo[cur].filetype == "neo-tree" then
          return
        end
        local listed = vim.fn.getbufinfo({ buflisted = 1 })
        if #listed > 1 then
          vim.cmd("BufferLineCyclePrev")
        end
        vim.cmd("bdelete " .. cur)
      end, { desc = "关闭当前标签页" })

      keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", { desc = "关闭其他标签页" })
    end,
  },
}
