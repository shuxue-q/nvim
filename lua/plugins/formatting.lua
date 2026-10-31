return {
  {
    "stevearc/conform.nvim",
    lazy = false, -- 启动即就绪，确保首次打开文件（BufReadPost）即可触发自动格式化
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "格式化当前代码",
      },
    },
    config = function()
      local conform = require("conform")

      -- 优先查找 PATH 中的 clang-format，若无则回退至 macOS Xcode 工具链自带路径
      local clang_format_cmd = vim.fn.exepath("clang-format")
      if clang_format_cmd == "" then
        local xcrun_path = vim.fn.trim(vim.fn.system({ "xcrun", "--find", "clang-format" }))
        if vim.v.shell_error == 0 and xcrun_path ~= "" then
          clang_format_cmd = xcrun_path
        else
          clang_format_cmd = "clang-format"
        end
      end

      conform.setup({
        formatters_by_ft = {
          c = { "clang_format_custom" },
          cpp = { "clang_format_custom" },
          cmake = { "gersemi", "neocmake_fmt", stop_after_first = true },
        },
        default_format_opts = {
          lsp_format = "fallback",
        },
        formatters = {
          clang_format_custom = {
            command = clang_format_cmd,
            -- 若工程中存在 .clang-format 则优先读取工程规则；否则按 100 列自动硬换行
            prepend_args = {
              "--style=file",
              "--fallback-style={BasedOnStyle: LLVM, ColumnLimit: 100}",
            },
          },
          gersemi = {
            prepend_args = { "--line-length", "100" },
          },
          neocmake_fmt = {
            command = "neocmakelsp",
            args = { "format", "-i", "$FILENAME" },
            stdin = false,
          },
        },
      })

      -- 判断当前缓冲区是否为可安全自动格式化的用户工程文件
      local excluded_prefixes = {
        "/usr/",
        "/Library/",
        "/System/",
        "/Applications/",
        "/opt/homebrew/",
        vim.fn.stdpath("data") .. "/",
      }

      local function should_autoformat(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return false
        end
        if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly then
          return false
        end
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" then
          return false
        end
        local real = (vim.uv or vim.loop).fs_realpath(name) or name
        for _, prefix in ipairs(excluded_prefixes) do
          if vim.startswith(real, prefix) then
            return false
          end
        end
        return true
      end

      local group = vim.api.nvim_create_augroup("user_auto_format", { clear = true })

      -- 1. 打开文件时异步自动格式化（跳过系统头文件与只读库文件，不阻塞界面）
      vim.api.nvim_create_autocmd("BufReadPost", {
        group = group,
        callback = function(ev)
          if should_autoformat(ev.buf) then
            vim.schedule(function()
              if should_autoformat(ev.buf) then
                conform.format({ bufnr = ev.buf, async = true })
              end
            end)
          end
        end,
      })

      -- 2. 保存文件与关闭窗口离开文件时自动格式化
      vim.api.nvim_create_autocmd({ "BufWritePre", "BufWinLeave" }, {
        group = group,
        callback = function(ev)
          if should_autoformat(ev.buf) then
            pcall(conform.format, { bufnr = ev.buf, timeout_ms = 3000 })
          end
        end,
      })
    end,
  },
}
