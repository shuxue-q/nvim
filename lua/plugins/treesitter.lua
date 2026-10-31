return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- Neovim 0.12+ 需使用重构后的 main 分支
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      -- C/C++ + CMake 工程所需解析器，以及基础配置高亮所需解析器
      local ensure_installed = {
        "c",
        "cpp",
        "cmake",
        "lua",
        "vim",
        "vimdoc",
        "markdown",
        "markdown_inline",
      }

      local missing = vim.tbl_filter(function(lang)
        return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
      end, ensure_installed)

      if #missing > 0 then
        ts.install(missing)
      end

      -- 打开对应文件类型时自动启用原生 Treesitter 语法高亮
      local group = vim.api.nvim_create_augroup("user_treesitter_highlight", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })

      -- 对启动时已存在的缓冲区也尝试开启高亮
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
          pcall(vim.treesitter.start, buf)
        end
      end
    end,
  },
}
