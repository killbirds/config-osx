-- fidget.nvim configuration
local ok, fidget = pcall(require, "fidget")
if not ok then
	return
end

-- fidget.nvim 설정 (최신 버전 기준 구성)
fidget.setup({
	-- LSP 진행 상태 관련 설정
	progress = {
		poll_rate = 0, -- Neovim 0.11에서 개선됨 (0으로 설정 시 자동 최적화)
		suppress_on_insert = false, -- 삽입 모드에서 새 메시지 억제
		ignore_done_already = false, -- 이미 완료된 새 작업 무시
		ignore_empty_message = false, -- 메시지가 없는 새 작업 무시
		-- LSP 서버 분리 시 알림 그룹 지우기
		clear_on_detach = function(client_id)
			local client = vim.lsp.get_client_by_id(client_id)
			return client and client.name or nil
		end,
		-- 진행 메시지의 알림 그룹 키 가져오기
		notification_group = function(msg)
			return msg.lsp_client.name
		end,
		ignore = {}, -- 무시할 LSP 서버 목록

		-- LSP 진행 메시지 표시 방법 설정
		display = {
			progress_icon = { pattern = "dots", period = 1 },
			done_icon = "✓", -- 완료 아이콘
			done_style = "Constant", -- 완료 스타일
			group_style = "Title", -- 그룹 스타일
			icon_style = "Question", -- 아이콘 스타일
			-- Neovim 0.11에서 지원되는 추가 설정
			render_limit = 5, -- 표시할 최대 작업 수
			skip_history = true, -- 히스토리 생략
			border = "rounded", -- 0.11에서 테두리 스타일 개선
			-- 0.11에서 지원되는 새로운 배경 설정
			backdrop = 0.8, -- 배경 어둡게 하기 (0-1 사이 값)

			-- 메시지 포맷 함수
			format_message = function(msg)
				local message = msg.message or ""
				local percentage = msg.percentage
				return string.format("%s%s", message, percentage and string.format(" (%.0f%%)", percentage) or "")
			end,

			-- 진행 주석 포맷 방법
			format_annote = function(msg)
				return msg.title or ""
			end,

			-- 진행 알림 그룹 이름 포맷 방법
			format_group_name = function(group)
				return tostring(group)
			end,

			-- 기본 알림 구성에서 옵션 재정의
			overrides = {
				rust_analyzer = { name = "rust-analyzer" },
				tsserver = { name = "typescript" },
				lua_ls = { name = "lua" },
			},
		},

		-- Neovim의 내장 LSP 클라이언트 관련 설정
		lsp = {
			progress_ringbuf_size = 0, -- 무제한(자동 관리)
			-- 0.11에서 개선된 진단 통합
			integrate_diagnostics = true,
			log_handler = false, -- LSP 핸들러 로깅 (디버깅용)
		},
	},

	-- 알림 하위 시스템 관련 설정
	notification = {
		poll_rate = 10, -- 폴링 주기 (ms)
		-- 기본 필터: 임계값 바탕으로 알림 필터링
		filter = vim.log.levels.INFO,
		history_size = 128, -- 기록에 보관할 제거된 메시지 수
		override_vim_notify = true, -- vim.notify() 자동 재정의 활성화

		-- Neovim 0.11 개선된 알림 창 설정
		window = {
			winblend = 0, -- 투명도 (0-100)
			border = "rounded", -- 테두리 스타일 ('none', 'single', 'double', 'rounded')
			max_width = 0, -- 최대 너비 (0=무제한)
			max_height = 0, -- 최대 높이 (0=무제한)
			x_padding = 1, -- 가로 패딩
			y_padding = 0, -- 세로 패딩
			align = "bottom", -- 정렬 ('top', 'bottom', 'left', 'right')
			relative = "editor", -- 위치 기준 ('editor', 'win')

			-- Neovim 0.11 전용 설정
			focusable = false, -- 포커스 가능 여부
			backdrop = 80, -- 배경 어둡게 설정 (0-100)
		},

		-- Neovim 0.11에서 개선된 알림 표시 설정
		view = {
			stack_upwards = true, -- 위로 쌓기
			icon_separator = " ", -- 아이콘 구분자
			group_separator = "---", -- 그룹 구분자
			group_separator_hl = "Comment", -- 그룹 구분자 하이라이트
			render_message = function(msg, cnt)
				if cnt == 1 then
					return msg
				else
					return string.format("%s (%dx)", msg, cnt)
				end
			end,
		},

		-- Neovim 0.11에서 개선된 히스토리 설정
		history = {
			size = 128, -- 히스토리 크기
		},

		-- 디버깅 설정
		debug = {
			logging = false, -- 로깅 활성화
			trace = false, -- 추적 활성화
		},

		-- 기본 알림 구성에서 옵션 재정의
		configs = {
			-- 기본 설정
			default = vim.deepcopy(fidget.notification.default_config),
		},
	},

	-- 다른 플러그인과의 통합 관련 설정
	integration = {
		["nvim-tree"] = {
			enable = true, -- nvim-tree 통합 활성화
		},
		["xcodebuild"] = {
			enable = true, -- Xcode 통합 활성화
		},
	},

	-- 로깅 관련 설정
	logger = {
		level = vim.log.levels.WARN, -- 최소 로깅 레벨
		max_size = 10000, -- 최대 로그 파일 크기(KB)
		float_precision = 0.01, -- 부동소수점 표시 소수점 자릿수 제한
		-- Fidget 로그 저장 위치
		path = string.format("%s/fidget.nvim.log", vim.fn.stdpath("cache")),
	},

	-- Neovim 0.11에서 개선된 LSP 문서 로딩/처리 시 시각적 표시
	progress_display = {
		done_ttl = 3, -- 완료 메시지 표시 시간 (초)
		done_icon = "✓", -- 완료 아이콘
		progress_ttl = 60, -- 진행 메시지 표시 시간 (초)
	},

	-- Neovim 0.11에서 개선된 LSP 서버 상태 표시
	lsp = {
		log_handler = true, -- LSP 로그 핸들러 활성화
		progress = true, -- LSP 진행 상황 표시 활성화
		hover = { max_width = 0, max_height = 0 }, -- 호버 창 최대 크기 (0=무제한)
		signature = { max_width = 0, max_height = 0 }, -- 시그니처 창 최대 크기 (0=무제한)
	},
})

-- 키 매핑 추가: 알림 히스토리 토글
vim.keymap.set("n", "<leader>fh", function()
	require("fidget.notification").show_history()
end, { desc = "Fidget: 알림 히스토리 보기" })

-- 키 매핑 추가: 알림 창 지우기
vim.keymap.set("n", "<leader>fc", function()
	require("fidget.notification").clear()
end, { desc = "Fidget: 알림 지우기" })

-- 0.11 전용 추가 설정 (버전 체크)
if vim.fn.has("nvim-0.11") == 1 then
	-- Neovim 0.11 알림 시스템 개선된 설정
	fidget.notification.opts({
		-- 알림 표시 방식 설정
		view = {
			stack_upwards = false, -- 아래로 쌓기
		},

		-- 향상된 알림 창 설정
		window = {
			winblend = 10, -- 약간의 투명도
			border = "rounded", -- 둥근 테두리
			zindex = 50, -- 알림 창 z-index
			max_width = 80, -- 알림 창 최대 너비
		},

		-- 0.11 전용 설정: 키보드로 알림 제어
		keymaps = {
			-- 알림 창 닫기
			close = "q",
			-- 알림 창 기록 보기
			history = "h",
		},
	})

	-- 개선된, 커서 모양 변경 없는 알림 시스템
	fidget.notification.set_group_config("default", {
		no_cursor_change = true, -- 커서 모양 유지
		annote = "nvim", -- 주석
	})
end
