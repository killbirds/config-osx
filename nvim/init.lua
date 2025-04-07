-- init
require("init")
require("keys")

-- 캐시 관리자 로드 (성능 최적화)
require("cache_manager").setup()

-- plugin manager
require("plugin")

-- fold settings
require("config.fold").setup()

-- 0.11 UI 기능 활성화
vim.o.mousemoveevent = true -- 마우스 이벤트 기능 활성화 (부동 창 호버 기능 등을 위해 필요)

-- 0.11 추가 기능 활성화
-- 터미널 개선 기능
vim.g.term_conceal = true -- 터미널 줄 숨김 기능 활성화
vim.g.term_reflow = true -- 터미널 리플로우 활성화

-- 0.11 성능 최적화 설정
vim.g._ts_force_sync_parsing = false -- Treesitter 비동기 파싱 사용

-- statuscolumn 개선 - 0.11에서 개선된 'statuscolumn' 기능 활용
vim.opt.statuscolumn = "%l %s"
