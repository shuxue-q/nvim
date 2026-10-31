return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    init = function()
      -- 确保插件尚未加载完成前的初始帧也保持全局状态栏
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        vim.o.statusline = " "
      else
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      vim.o.laststatus = vim.g.lualine_laststatus

      return {
        options = {
          theme = "tokyonight",
          globalstatus = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = { "dashboard", "alpha" },
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            "branch",
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
              -- 直接对接已安装的 mini.diff 状态统计
              source = function()
                local summary = vim.b.minidiff_summary
                if summary then
                  return {
                    added = summary.add or 0,
                    modified = summary.change or 0,
                    removed = summary.delete or 0,
                  }
                end
              end,
            },
            {
              "diagnostics",
              symbols = {
                error = " ",
                warn = " ",
                info = " ",
                hint = " ",
              },
            },
          },
          lualine_c = {
            {
              "filename",
              path = 1, -- 显示相对工程根目录路径
              symbols = {
                modified = " ●",
                readonly = " ",
                unnamed = "[未命名]",
              },
            },
          },
          lualine_x = {
            {
              "lsp_status",
              icon = "",
              symbols = {
                spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
                done = "✓",
                separator = ", ",
              },
              color = { fg = "#7aa2f7" },
            },
            "encoding",
            "fileformat",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        extensions = { "neo-tree", "lazy" },
      }
    end,
  },
}
