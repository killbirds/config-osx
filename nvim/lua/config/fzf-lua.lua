-- fzf-lua 설정 (telescope 대체)
--
-- telescope에서 이전할 때의 결정 사항:
--
-- 1. 제거된 플러그인 6개: telescope.nvim, telescope-fzf-native(make 빌드),
--    telescope-ui-select, telescope-smart-history, sqlite.lua(네이티브 sqlite),
--    plenary.nvim. fzf-lua는 fzf 바이너리에 위임하므로 컴파일 산출물이 없다.
--    plenary는 telescope만 실제로 쓰고 있었다(nvim-metals는 참조 0건,
--    nvim-autopairs는 _G.__is_log 디버그 플래그 뒤에만 있음).
--
-- 2. project.nvim 제거. Telescope projects picker가 사라지는 것 외에도,
--    detection_methods의 "lsp" 때문에 rust-analyzer가 보고하는 crate 소스
--    디렉토리(~/.cargo/registry/..., ~/.rustup/toolchains/...)까지 프로젝트로
--    등록돼 히스토리가 오염되고 있었다. upstream은 2023-04 이후 방치 상태다.
--    자동 chdir이 다시 필요하면 nvim-tree의 VimEnter cd(plugins/explorer.lua)와
--    LSP root 기반 cd로 대체할 수 있다.
--
-- 3. "telescope" 프로필을 베이스로 쓴다. 실제로 물려받는 것은 레이아웃
--    (width 0.8 / height 0.9, flex preview)이다. 하이라이트는 아래 6번 참고.
--
-- 4. 손버릇 보존 (man fzf 기준):
--      <C-n>/<C-p>  히스토리    -> --history 설정 시 next/prev-history로 자동 재매핑
--      <esc>        닫기        -> fzf 기본 abort (ctrl-c/ctrl-g/ctrl-q/esc)
--      <C-j>/<C-k>  항목 이동   -> fzf 기본 down/up이지만 그냥 두면 동작하지 않는다.
--                                 아래 winopts.on_create 주석 참고.
--    <C-h>(도움말), <C-o>(선택), <C-t>(trouble)는 아래에서 명시한다.
--
-- 6. picker 창 색은 Telescope* 그룹을 물려받지 않는다.
--    telescope 프로필은 Telescope 하이라이트가 살아 있을 때만 쓰는데
--    (profiles/telescope.lua의 hl_validate), catppuccin은 lazy의 plugin spec
--    이름으로 integration을 자동 탐지하므로 telescope spec이 사라진 뒤에는
--    Telescope* 그룹을 만들지 않는다. 실측: catppuccin 컴파일 캐시를 지우면
--    TelescopeNormal 등이 전부 UNDEFINED가 된다.
--    대신 catppuccin의 fzf integration이 FzfLua* 그룹을 테마링한다
--    (FzfLuaNormal -> NormalFloat, FzfLuaBorder -> FloatBorder 등).
--    즉 프로필의 hls / fzf_colors 블록은 no-op이고, 레이아웃(width/height,
--    flex preview)만 실제로 물려받는다.
--
-- 7. <leader>fP는 의미가 바뀌었다. 이전 `Telescope pickers`는 cache_picker
--    (num_pickers = 10)로 캐시된 최근 picker를 쿼리·결과까지 재개하는 기능이었다.
--    fzf-lua의 resume은 단일 슬롯(config.__resume_data)뿐이고 `builtin`은
--    사용 가능한 picker 목록을 새로 실행하는 것이다. 멀티 슬롯 재개는 대응물이 없다.
--
-- 5. 주의: keymap/actions 테이블은 [1] = true 가 없으면 기본값과 병합되지 않고
--    통째로 교체된다 (fzf-lua/lua/fzf-lua/config.lua:89, 100).
--    아래 테이블에 true를 남겨 둔 이유다.

local fzf = require("fzf-lua")
local fzf_actions = require("fzf-lua.actions")

-- <C-t>로 결과를 trouble에 넘긴다 (trouble README의 fzf-lua 레시피).
-- telescope 시절 open_with_trouble과 같은 역할이며, "telescope" 프로필이
-- ctrl-t에 걸어 둔 file_tabedit을 덮어쓴다.
local trouble_open = nil
do
	local ok, trouble_fzf = pcall(require, "trouble.sources.fzf")
	if ok and trouble_fzf.actions then
		trouble_open = trouble_fzf.actions.open
	end
end

-- telescope-smart-history + sqlite.lua 대체.
-- fzf는 --history가 있으면 ctrl-n/ctrl-p를 next/prev-history로 자동 재매핑한다
-- ("When enabled, CTRL-N and CTRL-P are automatically remapped" — man fzf).
-- sqlite DB 대신 picker별 평문 파일을 쓰고, 기존 telescope history.limit = 100을 옮긴다.
local history_dir = vim.fn.stdpath("state") .. "/fzf-lua-history"
vim.fn.mkdir(history_dir, "p")

---@param name string picker 이름 (히스토리 파일명으로 쓰인다)
local function history(name)
	return {
		["--history"] = history_dir .. "/" .. name,
		["--history-size"] = 100,
	}
end

fzf.setup({
	"telescope", -- 베이스 프로필

	-- vim.ui.select을 fzf-lua로 (telescope-ui-select 대체).
	-- 기존 ui-select 설정의 dropdown 느낌(width 0.8 + previewer 없음)을 옮긴다.
	-- 시그니처는 opts(ui_opts, items) (providers/ui_select.lua:109).
	ui_select = function(ui_opts, items)
		return vim.tbl_deep_extend("force", ui_opts or {}, {
			winopts = {
				width = 0.8,
				-- 항목 수에 맞춰 높이를 줄여 dropdown처럼 보이게 한다
				height = math.min(#items + 4, math.floor(vim.o.lines * 0.8)),
				preview = { hidden = true },
			},
		})
	end,

	winopts = {
		-- keys.lua가 터미널 모드 전역으로 <C-h>/<C-j>/<C-k>/<C-l>을 wincmd h/j/k/l에
		-- 묶어 두었다(keys.lua의 terminal 매핑). telescope 시절엔 prompt가 일반 버퍼라
		-- insert 모드 매핑이어서 충돌이 없었지만, fzf picker는 터미널 버퍼라서 이 전역
		-- 매핑이 fzf보다 먼저 키를 먹는다. 그대로 두면 <C-j>가 항목 이동이 아니라
		-- 아래 창으로 포커스를 옮겨 picker를 떠나 버린다(실측 확인).
		--
		-- fzf-lua가 <Esc>에 쓰는 것과 같은 passthrough 매핑으로 무력화한다
		-- (fzf-lua/lua/fzf-lua/win.lua:317-320이 "t", "<Esc>", "<Esc>"를 buffer-local로
		--  걸어 전역 매핑을 덮는 방식). <C-h>는 아래 keymap.builtin이 buffer-local
		-- toggle-help를 걸어 주므로 이미 해결된다.
		on_create = function(e)
			for _, key in ipairs({ "<C-j>", "<C-k>" }) do
				vim.keymap.set("t", key, key, { buffer = e.bufnr, nowait = true })
			end
		end,
	},

	keymap = {
		builtin = {
			true, -- 프로필/기본 키맵 상속 (F1~F9, <C-d>/<C-u> preview 스크롤 등)
			-- 기존 telescope <C-h> = actions.which_key
			["<C-h>"] = "toggle-help",
		},
		fzf = {
			true, -- 기본 fzf 바인딩 상속
		},
	},

	actions = {
		files = {
			true, -- 기본 파일 액션 상속 (enter, ctrl-s/v, alt-q, alt-i/h/f 등)
			-- 기존 telescope <C-o> = actions.select_default
			["ctrl-o"] = fzf_actions.file_edit_or_qf,
			-- 기존 telescope <C-t> = open_with_trouble
			-- trouble의 액션은 { fn = ..., prefix = ..., desc = ... } table인데
			-- fzf-lua의 주석은 fun(...)만 허용해 타입 경고가 난다. fzf-lua는 실제로
			-- action table을 받으므로(동작 확인됨) 경고만 억제한다.
			---@diagnostic disable-next-line: assign-type-mismatch
			["ctrl-t"] = trouble_open,
		},
	},

	-- 기존 telescope file_ignore_patterns를 옮긴다.
	-- 주의: fzf-lua의 file_ignore_patterns도 Lua 패턴이므로 .은 %.로 이스케이프한다
	-- (기존 설정에 남아 있던 주석과 같은 이유다).
	defaults = {
		file_ignore_patterns = { "node_modules/", "%.git/", "yarn%.lock", "%.cache/" },
	},

	files = {
		fzf_opts = history("files"),
	},

	grep = {
		fzf_opts = history("grep"),
		-- rg는 이미 .gitignore를 존중한다. hidden 파일은 alt-h로 토글.
	},

	buffers = {
		fzf_opts = history("buffers"),
		-- 기존 telescope buffers: sort_mru = true, ignore_current_buffer = true
		sort_lastused = true,
		ignore_current_buffer = true,
	},

	helptags = {
		fzf_opts = history("helptags"),
	},
})
