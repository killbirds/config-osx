return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("config.nvim-lint") -- 기존 설정 파일 로드
	end,
	dependencies = {
		-- 필요한 의존성 플러그인이 있다면 여기에 추가
	},
}
