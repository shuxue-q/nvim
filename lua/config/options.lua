-- 基础编辑器选项
local opt = vim.opt

-- 行号与外观
opt.number = true          -- 显示绝对行号
opt.relativenumber = true  -- 显示相对行号
opt.cursorline = true      -- 高亮当前行
opt.signcolumn = "yes"     -- 始终显示左侧符号列，防止文本抖动
opt.termguicolors = true   -- 启用 24 位真彩色
opt.laststatus = 3         -- 全局底部单状态栏（跨分屏与文件树统一显示）
opt.showmode = false       -- 不在命令行重复显示模式（已由状态栏展示）
opt.wrap = false           -- 禁用软换行（长行横向滚动，不折行）
opt.scrolloff = 8          -- 光标上下保留最少行数
opt.sidescrolloff = 8      -- 横向滚动时左右保留最少列数

-- 缩进（默认 2 空格）
opt.expandtab = true       -- 将 Tab 转换为空格
opt.tabstop = 2            -- Tab 显示宽度
opt.shiftwidth = 2         -- 自动缩进宽度
opt.smartindent = true     -- 智能自动缩进

-- 搜索
opt.ignorecase = true      -- 搜索忽略大小写
opt.smartcase = true       -- 包含大写字母时精确匹配大小写

-- 交互与窗口
opt.mouse = "a"            -- 启用鼠标支持
opt.clipboard = "unnamedplus" -- 与系统剪贴板同步
opt.splitright = true      -- 垂直分屏默认在右侧打开
opt.splitbelow = true      -- 水平分屏默认在下方打开
opt.updatetime = 250       -- 缩短响应等待时间
