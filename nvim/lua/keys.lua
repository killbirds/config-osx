-- 0.11 최적화된 키매핑 설정

-- jj로 <Esc> 대체
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, desc = "Exit insert mode with jj" })

-- ESC로 하이라이트 끄기 (init.lua에서 이동됨)
vim.keymap.set("n", "<Esc>", ":noh<CR>", { noremap = true, silent = true, desc = "Clear search highlight" })

-- 검색 하이라이트 제거 (추가 옵션)
vim.keymap.set("n", "<Leader><Space>", ":nohlsearch<CR>", { noremap = true, desc = "Clear search highlight" })

-- 시스템 클립보드 매핑 (+ 레지스터) - 0.11 최적화
local clipboard_opts = { noremap = true, silent = true }
vim.keymap.set("v", "<Leader>y", '"+y', vim.tbl_extend("force", clipboard_opts, { desc = "Copy to system clipboard" }))
vim.keymap.set("v", "<Leader>d", '"+d', vim.tbl_extend("force", clipboard_opts, { desc = "Cut to system clipboard" }))
vim.keymap.set(
  { "n", "v" },
  "<Leader>p",
  '"+p',
  vim.tbl_extend("force", clipboard_opts, { desc = "Paste from system clipboard after cursor" })
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>P",
  '"+P',
  vim.tbl_extend("force", clipboard_opts, { desc = "Paste from system clipboard before cursor" })
)

-- 창 크기 조정 - 0.11에서 향상된 성능으로 더 빠른 조정
local resize_opts = { noremap = true, silent = true }
vim.keymap.set("n", "<Up>", ":resize -5<CR>", vim.tbl_extend("force", resize_opts, { desc = "Decrease window height" }))
vim.keymap.set(
  "n",
  "<Down>",
  ":resize +5<CR>",
  vim.tbl_extend("force", resize_opts, { desc = "Increase window height" })
)
vim.keymap.set(
  "n",
  "<Left>",
  ":vertical resize -10<CR>",
  vim.tbl_extend("force", resize_opts, { desc = "Decrease window width" })
)
vim.keymap.set(
  "n",
  "<Right>",
  ":vertical resize +10<CR>",
  vim.tbl_extend("force", resize_opts, { desc = "Increase window width" })
)

-- 버퍼 탐색 - 0.11 기본 매핑과 중복되지 않는 추가 매핑
-- 주의: 0.11에서 [b, ]b 등이 기본 제공되므로 다른 키 사용
local buffer_opts = { noremap = true, silent = true }
vim.keymap.set("n", "<Leader>bn", ":bnext<CR>", vim.tbl_extend("force", buffer_opts, { desc = "Next buffer" }))
vim.keymap.set("n", "<Leader>bp", ":bprevious<CR>", vim.tbl_extend("force", buffer_opts, { desc = "Previous buffer" }))
vim.keymap.set("n", "<Leader>bd", ":Bdelete<CR>", vim.tbl_extend("force", buffer_opts, { desc = "Delete buffer" }))

-- 주의: 노멀 모드 <Tab> 매핑은 두지 않는다.
-- 대부분의 터미널에서 <Tab>과 <C-i>는 같은 키코드라서, <Tab>을 버퍼 전환에 쓰면
-- 점프리스트 앞으로 가기(<C-i>)가 사라진다. 버퍼 순환은 ]b/[b(기본 매핑) 또는
-- <Leader>bn/<Leader>bp를 사용한다.

-- 줄 이동 - 0.11 성능 최적화된 버전
local move_opts = { noremap = true, silent = true }
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", vim.tbl_extend("force", move_opts, { desc = "Move line down" }))
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", vim.tbl_extend("force", move_opts, { desc = "Move line up" }))
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi", vim.tbl_extend("force", move_opts, { desc = "Move line down" }))
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi", vim.tbl_extend("force", move_opts, { desc = "Move line up" }))
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", vim.tbl_extend("force", move_opts, { desc = "Move selection down" }))
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", vim.tbl_extend("force", move_opts, { desc = "Move selection up" }))

-- 터미널 모드 - 0.11에서 개선된 터미널 기능 활용
local terminal_opts = { noremap = true, silent = true }
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", vim.tbl_extend("force", terminal_opts, { desc = "Exit terminal mode" }))
vim.keymap.set(
  "t",
  "<C-h>",
  "<Cmd>wincmd h<CR>",
  vim.tbl_extend("force", terminal_opts, { desc = "Go to left window" })
)
vim.keymap.set(
  "t",
  "<C-j>",
  "<Cmd>wincmd j<CR>",
  vim.tbl_extend("force", terminal_opts, { desc = "Go to down window" })
)
vim.keymap.set("t", "<C-k>", "<Cmd>wincmd k<CR>", vim.tbl_extend("force", terminal_opts, { desc = "Go to up window" }))
vim.keymap.set(
  "t",
  "<C-l>",
  "<Cmd>wincmd l<CR>",
  vim.tbl_extend("force", terminal_opts, { desc = "Go to right window" })
)

vim.keymap.set(
  "n",
  "<Leader>tt",
  ":split | terminal<CR>i",
  vim.tbl_extend("force", terminal_opts, { desc = "Open terminal in horizontal split" })
)
vim.keymap.set(
  "n",
  "<Leader>tv",
  ":vsplit | terminal<CR>i",
  vim.tbl_extend("force", terminal_opts, { desc = "Open terminal in vertical split" })
)

-- 0.11 추가 매핑
-- 진단 관련 키맵은 config/diagnostics.lua에서 중앙 관리됨

-- 진단 모드 토글 키맵 추가
vim.keymap.set("n", "<Leader>dm", function()
  require("config.diagnostics").toggle_mode()
end, { desc = "Toggle diagnostic mode (default/performance/development)" })

-- 문서 심볼은 0.11 기본 매핑 gO를 사용한다 (중복 매핑 제거)

-- 주석 토글: Neovim 0.10+ 내장 gc/gcc에 <Leader>l을 연결한다.
-- 내장 gc/gcc 자체가 매핑이므로 remap = true가 필요하다.
vim.keymap.set("n", "<Leader>l", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set("x", "<Leader>l", "gc", { remap = true, desc = "Toggle comment selection" })

-- LSP completion 토글 (0.11 새 기능)
-- <Leader>l은 주석 토글이므로 지연을 피해 <Leader>L 네임스페이스 사용
vim.keymap.set("n", "<Leader>Lt", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client:supports_method("textDocument/completion") then
      if vim.b.lsp_completion_enabled then
        -- bufnr는 필수 인자다(nil이면 _resolve_bufnr가 현재 버퍼로 해석하지만
        --  아래 enable 분기와 형태를 맞춘다)
        vim.lsp.completion.enable(false, client.id, 0)
        vim.b.lsp_completion_enabled = false
        vim.notify("LSP completion disabled", vim.log.levels.INFO)
      else
        vim.lsp.completion.enable(true, client.id, 0, { autotrigger = true })
        vim.b.lsp_completion_enabled = true
        vim.notify("LSP completion enabled", vim.log.levels.INFO)
      end
      break
    end
  end
end, { desc = "Toggle LSP completion" })

-- 추가 유용한 매핑
vim.keymap.set("n", "<Leader>w", ":w<CR>", { noremap = true, silent = true, desc = "Save file" })
-- <Leader>q는 config/diagnostics.lua에서 진단 관련으로 사용됨.
-- <Leader>qq를 쓰면 <Leader>q가 timeoutlen만큼 대기하므로 종료는 <Leader>Q를 사용한다.
vim.keymap.set("n", "<Leader>Q", ":q<CR>", { noremap = true, silent = true, desc = "Quit" })
vim.keymap.set("n", "<Leader>x", ":x<CR>", { noremap = true, silent = true, desc = "Save and quit" })

-- 멀티커서(multicursor.nvim) 키:
-- <C-n>: 커서 아래 단어/선택의 다음 일치에 커서 추가
-- <C-Down>/<C-Up>: 아래/위 줄에 커서 추가 (<C-j>/<C-k>는 창 이동이라 피함)
-- <C-a>(visual): 모든 일치에 커서 추가, <leader>m*: 나머지
-- 자세한 설정은 config/multicursor.lua 참조

-- 오타 방지 명령어
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("WQ", "wq", {})

-- 0.11 기본 매핑 정보 (참고용 주석)
-- grn - LSP rename
-- grr - LSP references
-- gri - LSP implementation
-- gO - LSP document symbol
-- gra - LSP code action
-- CTRL-S (insert) - LSP signature help
-- [d, ]d - Diagnostic navigation
-- [q, ]q - Quickfix navigation
-- [l, ]l - Location list navigation
-- [b, ]b - Buffer list navigation
-- [<Space>, ]<Space> - Add empty lines
