-- 버퍼가 NvimTree가 아닌 경우에만 현재 버퍼를 강제로 삭제
vim.keymap.set("n", "<C-c>", function()
	local ft = vim.bo.filetype
	if ft ~= "NvimTree" and ft ~= "dashboard" then -- 추가 조건 예시
		local ok, err = pcall(require("bufdelete").bufdelete, 0, true)
		if not ok then
			vim.notify("Buffer deletion failed: " .. err, vim.log.levels.ERROR)
		end
	end
end, {
	silent = true,
	desc = "Force delete current buffer unless it's NvimTree or dashboard",
})
