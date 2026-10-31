return {
  {
    "folke/tokyonight.nvim",
    lazy = false,    -- 主配色方案在启动时立即加载
    priority = 1000, -- 确保在其他界面插件之前加载
    opts = {
      style = "night",     -- 可选: "storm", "night", "moon", "day"
      transparent = false, -- 是否启用透明背景
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
