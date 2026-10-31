return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "saghen/blink.cmp",
      "MeanderingProgrammer/render-markdown.nvim",
    },
    config = function()
      -- 开启行内诊断提示（Neovim 0.11+ 默认关闭 virtual_text）与圆角浮窗
      vim.diagnostic.config({
        virtual_text = { spacing = 2 },
        severity_sort = true,
        float = { border = "rounded", max_width = 88 },
      })

      -- 将 LSP 文档中的 Doxygen 注释标签（@brief / @param / @return / @note 等）结构化为易读 Markdown
      local function format_doxygen_lines(lines)
        local out = {}
        local in_fence = false

        local function trim_doc(s)
          return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
        end

        local function push_callout(kind, title_prefix, body)
          if #out > 0 and out[#out] ~= "" then
            table.insert(out, "")
          end
          table.insert(out, "> [!" .. kind .. "]")
          if title_prefix and title_prefix ~= "" then
            table.insert(out, "> " .. title_prefix .. (body ~= "" and (" " .. body) or ""))
          elseif body ~= "" then
            table.insert(out, "> " .. body)
          end
          table.insert(out, "")
        end

        for _, line in ipairs(lines) do
          if line:match("^%s*```") or line:match("^%s*~~~") then
            in_fence = not in_fence
            table.insert(out, line)
          elseif in_fence then
            table.insert(out, line)
          else
            local tag, rest = line:match("^%s*\\?[@\\]([%a_]+)%s*(.*)$")
            if not tag then
              table.insert(out, line)
            else
              local t = tag:lower()
              if t == "brief" or t == "short" or t == "details" then
                local desc = trim_doc(rest)
                if desc ~= "" then
                  table.insert(out, desc .. "  ")
                end
              elseif t == "param" then
                local dir, after_dir = rest:match("^%[%s*([%w_,%s]+)%s*%]%s*(.*)$")
                local target = after_dir or rest
                local name, desc = target:match("^([%w_%.%*]+)%s*[:%-—]?%s*(.*)$")
                desc = trim_doc(desc)
                if name then
                  local dir_badge = dir and string.format(" *(%s)*", trim_doc(dir)) or ""
                  if desc ~= "" then
                    table.insert(out, string.format("- **@param** `%s`%s — %s", name, dir_badge, desc))
                  else
                    table.insert(out, string.format("- **@param** `%s`%s", name, dir_badge))
                  end
                else
                  table.insert(out, "- **@param** " .. trim_doc(rest))
                end
              elseif t == "tparam" or t == "retval" or t == "throws" or t == "throw" or t == "exception" then
                local label = (t == "throw" or t == "exception") and "throws" or t
                local name, desc = rest:match("^([%w_%.%*:<>&]+)%s*[:%-—]?%s*(.*)$")
                desc = trim_doc(desc)
                if name and desc ~= "" then
                  table.insert(out, string.format("- **@%s** `%s` — %s", label, name, desc))
                elseif name then
                  table.insert(out, string.format("- **@%s** `%s`", label, name))
                else
                  table.insert(out, string.format("- **@%s** — %s", label, trim_doc(rest)))
                end
              elseif t == "return" or t == "returns" or t == "result" then
                table.insert(out, "- **@return** — " .. trim_doc(rest))
              elseif t == "see" or t == "sa" or t == "pre" or t == "post" or t == "since" or t == "version" then
                local label = (t == "sa") and "see" or t
                table.insert(out, string.format("- **@%s** — %s", label, trim_doc(rest)))
              elseif t == "note" or t == "remark" or t == "remarks" then
                push_callout("NOTE", nil, trim_doc(rest))
              elseif t == "warning" or t == "warn" or t == "attention" or t == "important" then
                push_callout("WARNING", nil, trim_doc(rest))
              elseif t == "deprecated" or t == "bug" then
                push_callout("CAUTION", "**@" .. t .. ":**", trim_doc(rest))
              else
                table.insert(out, line)
              end
            end
          end
        end

        -- 合并相邻 Doxygen 列表项（- **@...）之间的多余空行，使参数列表紧凑易读
        local compact = {}
        for i, line in ipairs(out) do
          local prev = compact[#compact]
          local nxt = out[i + 1]
          if
            line == ""
            and prev
            and prev:match("^%- %*%*@")
            and nxt
            and nxt:match("^%- %*%*@")
          then
            -- 跳过相邻标签项之间的空行
          else
            table.insert(compact, line)
          end
        end

        return compact
      end

      -- 拦截 LSP Markdown 转换入口（对 Hover / Signature Help / blink.cmp 文档窗统一生效）
      if not vim.lsp.util._doxygen_markdown_patched then
        vim.lsp.util._doxygen_markdown_patched = true
        local orig_convert = vim.lsp.util.convert_input_to_markdown_lines
        vim.lsp.util.convert_input_to_markdown_lines = function(input, contents)
          local start_idx = contents and (#contents + 1) or 1
          local res = orig_convert(input, contents)
          if type(res) ~= "table" or start_idx > #res then
            return res
          end
          local slice = vim.list_slice(res, start_idx, #res)
          local formatted = format_doxygen_lines(slice)
          for i = #res, start_idx, -1 do
            table.remove(res, i)
          end
          vim.list_extend(res, formatted)
          return res
        end
      end

      -- 全局向所有 LSP 服务注入 blink.cmp 的增强补全能力
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- 自动探测 CMakePresets.json / 常见构建目录下的 compile_commands.json
      local function find_compile_commands_dir(root_dir)
        if not root_dir then
          return nil
        end
        -- 若根目录已有 compile_commands.json 或 .clangd，交由 clangd 默认逻辑处理
        if
          vim.uv.fs_stat(root_dir .. "/compile_commands.json")
          or vim.uv.fs_stat(root_dir .. "/.clangd")
        then
          return nil
        end

        local candidates = {}
        local seen = {}
        local function add_candidate(dir)
          if not dir or dir == "" or dir:find("%$") then
            return
          end
          if not dir:match("^/") then
            dir = root_dir .. "/" .. dir
          end
          dir = vim.fs.normalize(dir)
          if seen[dir] then
            return
          end
          seen[dir] = true
          local stat = vim.uv.fs_stat(dir .. "/compile_commands.json")
          if stat then
            table.insert(candidates, {
              dir = dir,
              mtime = (stat.mtime and stat.mtime.sec) or 0,
            })
          end
        end

        -- 1. 解析 CMakeUserPresets.json / CMakePresets.json 中的 binaryDir
        for _, preset_file in ipairs({ "CMakeUserPresets.json", "CMakePresets.json" }) do
          local path = root_dir .. "/" .. preset_file
          if vim.uv.fs_stat(path) then
            local ok_read, lines = pcall(vim.fn.readfile, path)
            if ok_read and lines then
              local ok_json, data = pcall(vim.json.decode, table.concat(lines, "\n"))
              if ok_json and type(data) == "table" and type(data.configurePresets) == "table" then
                for _, preset in ipairs(data.configurePresets) do
                  if type(preset) == "table" and type(preset.binaryDir) == "string" then
                    local bin_dir = preset.binaryDir
                      :gsub("%${sourceDir}", root_dir)
                      :gsub("%${presetName}", tostring(preset.name or ""))
                    add_candidate(bin_dir)
                  end
                end
              end
            end
          end
        end

        -- 2. 兜底探测常见 CMake 构建目录
        for _, rel in ipairs({
          "build/debug",
          "build/release",
          "build/RelWithDebInfo",
          "build",
          "out/build/debug",
          "out/build/release",
        }) do
          add_candidate(rel)
        end

        if #candidates == 0 then
          return nil
        end
        -- 若同时存在多个构建目录（如 debug 和 release），优先选最近生成的 compile_commands.json
        table.sort(candidates, function(a, b)
          return a.mtime > b.mtime
        end)
        return candidates[1].dir
      end

      -- C/C++ 语言服务：clangd
      vim.lsp.config("clangd", {
        cmd = function(dispatchers, config)
          local cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--header-insertion=iwyu",
          }
          local cdb_dir = find_compile_commands_dir(config.root_dir)
          if cdb_dir then
            table.insert(cmd, "--compile-commands-dir=" .. cdb_dir)
          end
          return vim.lsp.rpc.start(cmd, dispatchers, {
            cwd = config.cmd_cwd,
            env = config.cmd_env,
            detached = config.detached,
          })
        end,
        -- 按列表顺序决定根目录优先级：优先匹配项目级标记，避免子目录 CMakeLists.txt 抢占根目录
        root_markers = {
          ".clangd",
          "compile_commands.json",
          "CMakeUserPresets.json",
          "CMakePresets.json",
          "compile_flags.txt",
          ".git",
          "CMakeLists.txt",
        },
      })

      -- CMake 语言服务：neocmakelsp (对应 lspconfig 名称为 neocmake)
      vim.lsp.config("neocmake", {
        cmd = { "neocmakelsp", "stdio" },
        filetypes = { "cmake" },
        root_markers = { "CMakeLists.txt", "CMakePresets.json", ".git" },
      })

      -- 启用 C/C++ 与 CMake 服务
      vim.lsp.enable({ "clangd", "neocmake" })

      -- 辅助函数：在 Normal 模式下滚动当前已打开的 LSP 悬浮预览窗口
      local function scroll_lsp_float(delta)
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if win ~= vim.api.nvim_get_current_win() and vim.api.nvim_win_is_valid(win) then
            local cfg = vim.api.nvim_win_get_config(win)
            local buf = vim.api.nvim_win_get_buf(win)
            if cfg.relative ~= "" and vim.bo[buf].buftype == "nofile" then
              local total = vim.api.nvim_buf_line_count(buf)
              local height = vim.api.nvim_win_get_height(win)
              if total > height then
                vim.api.nvim_win_call(win, function()
                  local view = vim.fn.winsaveview()
                  local max_top = math.max(1, total - height + 1)
                  view.topline = math.max(1, math.min(max_top, view.topline + delta))
                  view.lnum = math.max(view.topline, math.min(total, view.lnum + delta))
                  vim.fn.winrestview(view)
                end)
                return true
              end
            end
          end
        end
        return false
      end

      -- LSP 连接缓冲区后绑定常用代码导航快捷键
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(ev)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
          end

          map("gd", vim.lsp.buf.definition, "跳转到定义")
          map("gD", vim.lsp.buf.declaration, "跳转到声明")
          map("gr", vim.lsp.buf.references, "查找引用")
          map("gi", vim.lsp.buf.implementation, "跳转到实现")
          map("K", function()
            vim.lsp.buf.hover({
              border = "rounded",
              max_width = 88,
              max_height = 25,
            })
          end, "查看悬浮文档与签名")
          map("<C-k>", function()
            vim.lsp.buf.signature_help({
              border = "rounded",
              max_width = 88,
              max_height = 20,
            })
          end, "查看函数签名与参数提示")
          map("<C-f>", function()
            if not scroll_lsp_float(4) then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-f>", true, false, true), "n", false)
            end
          end, "向下滚动悬浮文档 / 翻页")
          map("<C-b>", function()
            if not scroll_lsp_float(-4) then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-b>", true, false, true), "n", false)
            end
          end, "向上滚动悬浮文档 / 翻页")
          map("<leader>rn", vim.lsp.buf.rename, "重命名符号")
          map("<leader>ca", vim.lsp.buf.code_action, "代码动作 (Code Action)")
          map("<leader>d", vim.diagnostic.open_float, "查看当前行诊断详情")
        end,
      })
    end,
  },
}
