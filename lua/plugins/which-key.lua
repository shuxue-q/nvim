return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      win = {
        border = "rounded",
      },
      spec = {
        { "<leader>b", group = "标签页 (Buffer)" },
        { "<leader>c", group = "代码操作 (Code)" },
        { "<leader>g", group = "Git 操作 (Git)" },
        { "<leader>r", group = "重命名/重构 (Rename)" },
        { "<leader>e", desc = "打开/关闭左侧文件树" },
        { "<leader>l", desc = "打开 Lazy 插件管理器" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "查看当前缓冲区快捷键 (WhichKey)",
      },
    },
  },
}
