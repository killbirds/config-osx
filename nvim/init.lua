-- init
require("init")
require("keys")

-- plugin manager
require("plugin")

-- fold settings
require("config.fold").setup()

-- 0.11 UI 기능 활성화 (필요 시 주석 제거)
-- vim.o.mousemoveevent = true

-- 혼합 인덴트 처리 (아직 0.11에서 지원되지 않음)
-- vim.opt.smoothindent = true
