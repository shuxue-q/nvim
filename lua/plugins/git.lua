return {
  {
    "nvim-mini/mini.diff",
    lazy = false, -- 启动即跟踪 Git 状态，支持随时执行 :GitDiff
    opts = {
      view = {
        style = "sign",
        signs = {
          add = "▎",
          change = "▎",
          delete = "",
        },
      },
      mappings = {
        apply = "gh",      -- 应用选中的 Git 修改块
        reset = "gH",      -- 还原选中的 Git 修改块
        textobject = "gh", -- Git 修改块文本对象
        goto_first = "[H", -- 跳到首个修改处
        goto_prev = "[h",  -- 跳到上一处修改
        goto_next = "]h",  -- 跳到下一处修改
        goto_last = "]H",  -- 跳到末个修改处
      },
    },
    config = function(_, opts)
      local minidiff = require("mini.diff")
      minidiff.setup(opts)

      local function toggle_git_diff()
        local bufnr = vim.api.nvim_get_current_buf()
        local data = minidiff.get_buf_data(bufnr)
        if not data then
          vim.notify("当前文件未纳入 Git 版本控制，无法显示 Git Diff", vim.log.levels.WARN)
          return
        end
        minidiff.toggle_overlay(bufnr)
        -- 保持不启用软换行，长行由格式化器负责硬换行
        vim.wo.wrap = false
      end

      -- 注册 :GitDiff 命令（仅对当前文件标签页切换行内 Diff 模式）
      vim.api.nvim_create_user_command("GitDiff", toggle_git_diff, {
        desc = "切换当前标签页的行内 Git Diff 查看模式",
      })

      -- 注册 <Space>gd 快捷键
      vim.keymap.set("n", "<leader>gd", toggle_git_diff, {
        desc = "切换当前标签页 Git Diff",
      })
    end,
  },
}
