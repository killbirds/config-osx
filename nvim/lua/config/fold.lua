-- 코드 접기 설정
local M = {}

-- 기본 접기 설정
function M.setup()
	-- 접기 방식 설정
	vim.opt.foldmethod = "expr"
	vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

	-- 기본적으로 모든 접기를 펼친 상태로 시작
	vim.opt.foldenable = false
	vim.opt.foldlevel = 99

	-- 접기 텍스트 사용자 정의
	vim.opt.foldtext = "v:lua.custom_fold_text()"

	-- 접기 열 너비 설정
	vim.opt.fillchars = "fold: "

	-- 사용자 정의 접기 텍스트 함수
	_G.custom_fold_text = function()
		local line = vim.fn.getline(vim.v.foldstart)
		local line_count = vim.v.foldend - vim.v.foldstart + 1
		local indent = string.match(line, "^%s*") or ""

		-- 주석 기호 제거
		line = line:gsub("^%s*[/%-#*]+%s*", "")

		-- 접기 표시 텍스트 생성
		local fold_info = " ⚡ " .. line_count .. " lines "

		-- 최종 접기 텍스트 생성
		return indent .. "▶ " .. line .. fold_info
	end

	-- 자동 명령 설정
	local augroup = vim.api.nvim_create_augroup("FoldConfig", { clear = true })

	-- 파일 열 때 접기 상태 복원
	vim.api.nvim_create_autocmd("BufReadPost", {
		group = augroup,
		pattern = "*",
		callback = function()
			if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
				vim.cmd([[silent! normal! g`"zv]])
			end
		end,
	})

	-- 키 매핑 설정
	vim.keymap.set("n", "<leader>z", "za", { noremap = true, desc = "Toggle fold" })
	vim.keymap.set("n", "<leader>Z", "zA", { noremap = true, desc = "Toggle all folds" })
	vim.keymap.set("n", "zR", function()
		vim.opt.foldenable = false
	end, { noremap = true, desc = "Open all folds" })
	vim.keymap.set("n", "zM", function()
		vim.opt.foldenable = true
	end, { noremap = true, desc = "Close all folds" })
end

return M
