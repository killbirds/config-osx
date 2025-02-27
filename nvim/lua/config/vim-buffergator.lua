-- Buffergator 창을 오른쪽에 배치
vim.g.buffergator_viewport_split_policy = "R"

-- 기본 단축키 비활성화 (사용자가 직접 지정할 예정)
vim.g.buffergator_suppress_keymaps = 1

-- MRU(최근 사용한 버퍼) 기반 순환 활성화 (필요하면 주석 해제)
-- vim.g.buffergator_mru_cycle_loop = 1

-- 이전 버퍼로 이동
vim.keymap.set("n", "<C-I>", ":BuffergatorMruCyclePrev<CR>", { silent = true })

-- 다음 버퍼로 이동
vim.keymap.set("n", "<C-O>", ":BuffergatorMruCycleNext<CR>", { silent = true })

-- 모든 버퍼 목록 보기
vim.keymap.set("n", "<leader>bl", ":BuffergatorOpen<CR>", { silent = true })

-- 새로운 빈 버퍼 열기 (버퍼 닫기와 동일한 개념)
vim.keymap.set("n", "<leader>T", ":enew<CR>", { silent = true })

-- 버퍼를 닫고 이전 버퍼로 전환 (필요 시 주석 해제)
-- vim.keymap.set("n", "<leader>bq", ":bp <BAR> bd #<CR>", { silent = true })
