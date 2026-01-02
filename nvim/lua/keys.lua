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

-- Tab 키는 snippet과 충돌할 수 있으므로 조건부 매핑
-- 0.11에서는 snippet이 있을 때만 Tab 사용, 아니면 버퍼 전환
vim.keymap.set("n", "<Tab>", function()
  if vim.snippet and vim.snippet.active() then
    return "<Tab>"
  else
    vim.cmd("bnext")
  end
end, vim.tbl_extend("force", buffer_opts, { desc = "Next buffer or snippet jump", expr = true }))

vim.keymap.set("n", "<S-Tab>", function()
  if vim.snippet and vim.snippet.active() then
    return "<S-Tab>"
  else
    vim.cmd("bprevious")
  end
end, vim.tbl_extend("force", buffer_opts, { desc = "Previous buffer or snippet jump", expr = true }))

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

-- 새로운 gO 매핑과 보완되는 매핑
vim.keymap.set("n", "<Leader>go", vim.lsp.buf.document_symbol, { desc = "Document symbols (complement to gO)" })

-- LSP completion 토글 (0.11 새 기능)
vim.keymap.set("n", "<Leader>lc", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client.supports_method("textDocument/completion") then
      if vim.b.lsp_completion_enabled then
        vim.lsp.completion.enable(false, client.id)
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
-- <Leader>q는 config/diagnostics.lua에서 진단 관련으로 사용됨
vim.keymap.set("n", "<Leader>qq", ":q<CR>", { noremap = true, silent = true, desc = "Quit" })
vim.keymap.set("n", "<Leader>x", ":x<CR>", { noremap = true, silent = true, desc = "Save and quit" })

-- vim-visual-multi 관련 설명
-- 기본 키 매핑:
-- <C-n>: 커서 아래 단어 선택 및 다음 일치 항목 찾기
-- <C-j>/<C-k>: 커서를 위/아래로 추가
-- <S-Left/Right>: 선택 영역 확장/축소
-- 자세한 설정은 config/vim-visual-multi.lua 파일 참조

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
