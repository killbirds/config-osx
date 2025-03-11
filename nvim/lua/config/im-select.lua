-- im-select.nvim 설정
-- macOS에서 한글 입력 전환을 자동으로 관리합니다.

require("im_select").setup({
	-- macOS에서 기본 영문 입력 방식
	-- `macism`을 실행하여 현재 사용 중인 입력 방식 목록을 확인할 수 있습니다
	default_im_select = "com.apple.keylayout.ABC",

	-- 입력 전환 명령어 설정
	-- macOS에서는 macism 사용 (homebrew로 설치)
	-- 다른 플랫폼: Windows - "im-select.exe", Linux - "fcitx5-remote"/"fcitx-remote"/"ibus"
	default_command = "macism",

	-- 모드 전환 시 자동으로 영문 입력으로 전환하는 이벤트
	-- 노멀 모드로 돌아갈 때, vim 시작 시, 포커스 획득 시, 명령 모드 종료 시, 비주얼 모드 진입 시(*:v, *:V, *:CTRL-V)
	set_default_events = {
		"VimEnter",
		"FocusGained",
		"InsertLeave",
		"CmdlineLeave",
	},

	-- 이전 입력 방식으로 돌아가는 이벤트
	-- 빈 테이블이면 이전 입력 방법 복원 기능 비활성화 (항상 영문으로 시작)
	-- 편집 모드 시작 시 이전 입력 방식으로 돌아가게 하려면 {"InsertEnter"} 설정
	set_previous_events = {},

	-- 실행 파일이 없을 때 경고 메시지 표시 여부
	keep_quiet_on_no_binary = false,

	-- 비동기 전환 활성화 (성능 향상)
	async_switch_im = true,
})
