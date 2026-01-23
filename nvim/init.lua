-- init
require("init")
require("keys")

-- 유틸리티 함수 로드
require("utils")

-- 캐시 관리자 로드 (성능 최적화)
require("cache_manager").setup()

-- plugin manager
require("plugin")

-- fold settings
require("config.fold").setup()

-- 0.11 기능 활용 (최소 버전이므로 분기 불필요)
-- UI 개선 사항
vim.o.mousemoveevent = true -- 마우스 이벤트 기능 활성화 (부동 창 호버 기능 등)

-- 터미널 개선 기능
vim.g.term_conceal = true -- 터미널 줄 숨김 기능 활성화
vim.g.term_reflow = true  -- 터미널 리플로우 활성화

-- Treesitter 비동기 파싱 활성화
vim.g._ts_force_sync_parsing = false

-- OSC 52 클립보드 지원 활성화
vim.g.termfeatures = { osc52 = true }

-- 중앙화된 진단 설정 로드
require("config.diagnostics").setup()

-- statuscolumn 개선 - 0.11에서 개선된 기능 활용
vim.opt.statuscolumn = "%l %s"

-- 새로운 윈도우 테두리 기본값 설정
-- vim.o.winborder = "rounded"

-- 새로운 completeopt 옵션 활용
vim.opt.completeopt = { "menuone", "noselect", "fuzzy", "preinsert" }

-- 새로운 wildmode 옵션
vim.opt.wildmode:append("noselect")
