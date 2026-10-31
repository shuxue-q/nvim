return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- 锁定稳定版，自动拉取预编译的 Rust 二进制文件
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets", -- 常用代码片段库（含 C/C++ 与 CMake 片段）
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- VSCode 风格快捷键：<C-n>/<C-p> 或上下方向键切换，Tab 确认补全/跳转片段
      keymap = {
        preset = "super-tab",
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          treesitter_highlighting = true,
          window = {
            border = "rounded",
            max_width = 88,
            max_height = 25,
          },
        },
        menu = {
          border = "rounded",
        },
      },

      -- 默认补全来源：LSP、文件路径、代码片段、当前缓冲区词条
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      -- 输入函数参数时自动显示函数签名 + 参数高亮 + 格式化注释浮窗
      signature = {
        enabled = true,
        trigger = {
          enabled = true,
          show_on_trigger_character = true,
          show_on_insert_on_trigger_character = true,
        },
        window = {
          border = "rounded",
          max_width = 100,
          max_height = 20,
          treesitter_highlighting = true,
          show_documentation = true,
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
