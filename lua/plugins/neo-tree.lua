return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false, -- 支持直接 `nvim .` 打开目录时接管文件树
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle left<CR>", desc = "打开/关闭左侧文件树" },
    },
    opts = {
      close_if_last_window = true, -- 若只剩文件树窗口则自动退出 Neovim
      popup_border_style = "rounded",
      window = {
        position = "left",
        width = 30,
      },
      filesystem = {
        follow_current_file = {
          enabled = true, -- 自动定位并展开当前正在编辑的文件
        },
        use_libuv_file_watcher = true, -- 实时监听外部文件增删变动（如 CMake 构建产物）
        filtered_items = {
          hide_dotfiles = false,   -- 显示 .clang-format / .clangd / .gitignore 等隐藏配置
          hide_gitignored = false, -- 显示 build/ 等目录
        },
      },
    },
  },
}
