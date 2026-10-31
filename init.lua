-- Neovim 主入口配置
-- 注意：options 和 keymaps（包含 Leader 键设置）必须在加载 lazy.nvim 之前引入
require("config.options")
require("config.keymaps")
require("config.lazy")
