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

-- completeopt는 nvim-cmp(config/nvim-cmp.lua)가 소유한다.
-- cmp가 InsertEnter 시 전역 completeopt를 덮어쓰므로 여기서 설정하면 무시된다.

-- 새로운 wildmode 옵션
vim.opt.wildmode:append("noselect")
