-- fidget.nvim configuration
local ok, fidget = pcall(require, "fidget")
if not ok then
	return
end

-- fidget.nvim 설정 (공식 예제 참조)
fidget.setup({
	-- LSP 진행 상태 관련 설정
	progress = {
		poll_rate = 0, -- 진행 메시지 폴링 빈도
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
			render_limit = 16, -- 한 번에 표시할 LSP 메시지 수
			done_ttl = 3, -- 완료 후 메시지 지속 시간(초)
			done_icon = "✓", -- 완료 아이콘
			progress_ttl = math.huge, -- 진행 중 메시지 지속 시간
			progress_icon = { pattern = "dots" }, -- 진행 중 아이콘

			-- 메시지 포맷 함수
			format_message = function(msg)
				return msg.message or ""
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
			},
		},

		-- Neovim의 내장 LSP 클라이언트 관련 설정
		lsp = {
			progress_ringbuf_size = 0, -- LSP 진행 링 버퍼 크기
			log_handler = false, -- LSP 핸들러 로깅 (디버깅용)
		},
	},

	-- 알림 하위 시스템 관련 설정
	notification = {
		poll_rate = 10, -- 알림 업데이트 및 렌더링 빈도
		filter = vim.log.levels.INFO, -- 최소 알림 레벨
		history_size = 128, -- 기록에 보관할 제거된 메시지 수
		override_vim_notify = false, -- vim.notify() 자동 재정의

		-- 알림 텍스트 렌더링 관련 설정
		view = {
			stack_upwards = true, -- 아래에서 위로 알림 항목 표시
			icon_separator = " ", -- 그룹 이름과 아이콘 사이 구분자
			group_separator = "---", -- 알림 그룹 간 구분자

			-- 알림 메시지 렌더링 방법
			render_message = function(msg, cnt)
				return cnt == 1 and msg or string.format("(%dx) %s", cnt, msg)
			end,
		},

		-- 알림 창 및 버퍼 관련 설정
		window = {
			winblend = 0, -- 알림 창의 배경색 투명도
			border = "none", -- 알림 창 테두리
			zindex = 45, -- 알림 창의 스택 우선순위
			max_width = 0, -- 알림 창 최대 너비
			max_height = 0, -- 알림 창 최대 높이
			x_padding = 1, -- 윈도우 경계에서 오른쪽 여백
			y_padding = 0, -- 윈도우 경계에서 아래쪽 여백
			align = "bottom", -- 알림 창 정렬 방법
			relative = "editor", -- 알림 창 위치 기준
		},
	},

	-- 다른 플러그인과의 통합 관련 설정
	integration = {
		["nvim-tree"] = {
			enable = true, -- nvim-tree.lua 통합 (설치된 경우)
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
})
