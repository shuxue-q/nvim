return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    event = { "BufReadPre", "BufNewFile", "LspAttach", "VeryLazy" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      file_types = { "markdown" },
      render_modes = true,
      anti_conceal = {
        enabled = true,
      },
      heading = {
        sign = false,
        border = false,
      },
      code = {
        sign = false,
        width = "block",
        right_pad = 2,
        border = "thin",
      },
      dash = {
        width = 80,
      },
      -- 对 LSP Hover / Signature 等无文件类型浮窗（buftype = nofile）启用零延迟与紧凑样式
      overrides = {
        buftype = {
          nofile = {
            debounce = 0,
            render_modes = true,
            padding = { highlight = "NormalFloat" },
            sign = { enabled = false },
            code = {
              style = "normal",
              width = "full",
              left_pad = 0,
              right_pad = 0,
              border = "none",
            },
          },
        },
      },
    },
  },
}
