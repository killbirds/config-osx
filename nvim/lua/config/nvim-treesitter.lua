require("nvim-treesitter.configs").setup({
	modules = {},

	-- 설치할 파서 목록 (필요한 언어 추가/제거 가능)
	ensure_installed = {
		"scala",
		"typescript",
		"javascript",
		"rust",
		"toml",
		"python",
		"html",
		"css",
		"lua", -- Lua 추가 (Neovim 설정에 유용)
		"query", -- Treesitter 쿼리 언어 (플레이그라운드용)
		"vimdoc", -- Neovim 문서 파서 (0.11에서 개선됨)
	},

	-- 동기 설치 여부 (ensure_installed에만 적용)
	sync_install = false, -- 비동기로 설치하여 시작 시간 단축

	-- 버퍼 진입 시 누락된 파서 자동 설치
	auto_install = true, -- 편리함을 위해 활성화 (Mason과의 통합 고려)

	-- 설치에서 제외할 파서
	ignore_install = { "haskell", "php" }, -- 사용하지 않는 언어 제외 예시

	-- 구문 강조 설정
	highlight = {
		enable = true, -- Treesitter 기반 하이라이팅 활성화
		disable = function(lang, buf)
			-- 큰 파일에서 성능 문제 방지
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
			-- 특정 언어 제외
			return vim.tbl_contains({ "lua", "rust" }, lang)
		end,
		additional_vim_regex_highlighting = false, -- Vim 기본 하이라이팅 비활성화 (충돌 방지)
	},

	-- 들여쓰기 설정
	indent = {
		enable = true, -- Treesitter 기반 들여쓰기 활성화
		disable = { "yaml", "python" }, -- Python은 기본 indent가 더 나을 수 있음
	},

	-- 점진적 선택 설정
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-space>", -- C-n 대신 C-space 사용 (vim-visual-multi와 충돌 방지)
			node_incremental = "<C-space>", -- C-n 대신 C-space 사용
			node_decremental = "<C-b>", -- 노드 축소
			scope_incremental = "<C-s>", -- 범위 확장
		},
	},

	-- 코드 접기 설정
	fold = {
		enable = true, -- Treesitter 기반 접기 활성화
		disable = { "markdown", "text" }, -- 접기 비활성화 언어
	},

	-- 추가 모듈 설정 (선택적)
	playground = {
		enable = true, -- Treesitter Playground 활성화 (쿼리 테스트용)
		disable = {},
		updatetime = 25, -- 빠른 업데이트
		keybindings = {
			toggle_query_editor = "o",
			toggle_hl_groups = "i",
			toggle_injected_languages = "t",
		},
	},

	-- 텍스트 객체 설정 (선택적)
	textobjects = {
		select = {
			enable = true,
			lookahead = true, -- 다음 객체를 미리 탐지
			keymaps = {
				["af"] = "@function.outer", -- 함수 외부 선택
				["if"] = "@function.inner", -- 함수 내부 선택
				["ac"] = "@class.outer", -- 클래스 외부 선택
				["ic"] = "@class.inner", -- 클래스 내부 선택
			},
		},
	},

	-- 0.11 추가 기능: 문법 트리 시각화 개선
	tree_docs = {
		enable = true, -- 문서화 지원 활성화
	},

	-- 0.11 추가 기능: 자동 태그 닫기
	autotag = {
		enable = true, -- HTML/JSX 태그 자동 닫기
		filetypes = { "html", "xml", "jsx", "tsx", "javascriptreact", "typescriptreact" },
	},
})

-- 접기 관련 전역 설정 (선택적)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false -- 기본적으로 접힌 상태로 시작하지 않음
vim.opt.foldlevel = 99 -- 초기 접기 레벨 설정

-- Neovim 0.11 개선된 Treesitter 지원 설정
-- TreesitterContext 플러그인 자동 로드 (없으면 무시됨)
local has_context, ts_context = pcall(require, "treesitter-context")
if has_context then
	ts_context.setup({
		enable = true, -- 컨텍스트 표시 활성화
		max_lines = 5, -- 최대 표시 줄 수
		min_window_height = 20, -- 최소 윈도우 높이
		multiline_threshold = 5, -- 여러 줄 컨텍스트 표시 임계값
		trim_scope = "inner", -- 컨텍스트 범위 조정
	})
end

-- 새로운 파서 퍼포먼스 설정 (Neovim 0.11+ 지원)
-- 0.11에서는 이러한 설정이 더 세밀하게 가능
vim.g.ts_slow_file_size = 1024 * 1024 -- 1MB 이상은 느린 파일로 처리
vim.g.ts_highlight_timeout = 200 -- 하이라이팅 시간 제한 (ms)
