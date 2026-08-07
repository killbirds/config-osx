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

-- 최소 지원 버전은 0.12이므로 아래 기능들은 버전 분기 없이 그대로 쓴다.
-- (개별 기능이 도입/개선된 버전은 각 주석에 그대로 남겨 둔다)
-- UI 개선 사항
vim.o.mousemoveevent = true -- 마우스 이벤트 기능 활성화 (부동 창 호버 기능 등)

-- OSC 52 클립보드 지원 활성화
local termfeatures = vim.g.termfeatures or {}
termfeatures.osc52 = true
vim.g.termfeatures = termfeatures

-- 중앙화된 진단 설정 로드
require("config.diagnostics").setup()

-- statuscolumn 개선 - 0.11에서 개선된 기능 활용
vim.opt.statuscolumn = "%l %s"

-- 새로운 윈도우 테두리 기본값 설정
-- vim.o.winborder = "rounded"

-- completeopt는 lua/init.lua가 소유한다.
-- blink.cmp는 자체 메뉴를 그리므로 completeopt를 읽지 않는다. 따라서 이 옵션은
-- 내장 완성(<C-x><C-o>, <leader>Lt로 켜는 vim.lsp.completion)에만 영향을 준다.

-- 새로운 wildmode 옵션
vim.opt.wildmode:append("noselect")
