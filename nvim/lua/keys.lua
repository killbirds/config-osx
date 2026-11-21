-- 0.11 최적화된 키매핑 설정

-- jj로 <Esc> 대체
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, desc = "Exit insert mode with jj" })

-- ESC로 하이라이트 끄기 (init.lua에서 이동됨)
vim.keymap.set("n", "<Esc>", ":noh<CR>", { noremap = true, silent = true, desc = "Clear search highlight" })

-- 검색 하이라이트 제거 (추가 옵션)
vim.keymap.set("n", "<Leader><Space>", ":nohlsearch<CR>", { noremap = true, desc = "Clear search highlight" })

-- 시스템 클립보드 매핑 (+ 레지스터) - 0.11 최적화
-- 비주얼 쪽은 "v"가 아니라 "x"로 건다. "v"는 select 모드(스니펫 placeholder)에도 걸려서,
-- placeholder를 Space로 시작하는 글자로 덮어쓸 때 timeoutlen만큼 멈추고 <Space>p 같은
-- 조합은 글자 대신 매핑이 실행된다. 이 파일의 다른 비주얼 매핑도 같은 이유로 "x"다.
local clipboard_opts = { noremap = true, silent = true }
vim.keymap.set("x", "<Leader>y", '"+y', vim.tbl_extend("force", clipboard_opts, { desc = "Copy to system clipboard" }))
vim.keymap.set("x", "<Leader>d", '"+d', vim.tbl_extend("force", clipboard_opts, { desc = "Cut to system clipboard" }))
vim.keymap.set(
  { "n", "x" },
  "<Leader>p",
  '"+p',
  vim.tbl_extend("force", clipboard_opts, { desc = "Paste from system clipboard after cursor" })
)
vim.keymap.set(
  { "n", "x" },
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
vim.keymap.set("x", "<A-j>", ":m '>+1<CR>gv=gv", vim.tbl_extend("force", move_opts, { desc = "Move selection down" }))
vim.keymap.set("x", "<A-k>", ":m '<-2<CR>gv=gv", vim.tbl_extend("force", move_opts, { desc = "Move selection up" }))

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

-- 이 버퍼의 자동완성 토글.
-- 완성 엔진은 blink.cmp 하나다. 예전 토글은 blink를 둔 채 내장 vim.lsp.completion을 켜서
-- 메뉴 두 개가 함께 떴다. blink는 vim.b.completion == false인 버퍼에서 동작하지 않는다
-- (blink/cmp/config/init.lua의 enabled 판정). cmdline 완성은 영향받지 않는다.
-- <Leader>l은 주석 토글이므로 지연을 피해 <Leader>L 네임스페이스 사용
vim.keymap.set("n", "<Leader>Lt", function()
  vim.b.completion = vim.b.completion == false
  if not vim.b.completion and package.loaded["blink.cmp"] then
    require("blink.cmp").hide()
  end
  vim.notify("Completion " .. (vim.b.completion and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle completion (buffer)" })

-- undo 트리 창 토글 (내장 nvim.undotree, 명령은 config/undotree.lua가 만든다). 창 안에서 커서를
-- 옮기면 그 시점으로 되돌아간다. <Leader>u로 시작하는 다른 키가 없어 timeoutlen을 기다리지 않는다.
vim.keymap.set("n", "<Leader>u", "<Cmd>Undotree<CR>", { silent = true, desc = "Toggle undo tree" })

-- 추가 유용한 매핑
vim.keymap.set("n", "<Leader>w", ":w<CR>", { noremap = true, silent = true, desc = "Save file" })
-- <Leader>q는 config/diagnostics.lua에서 진단 관련으로 사용됨.
-- <Leader>qq를 쓰면 <Leader>q가 timeoutlen만큼 대기하므로 종료는 <Leader>Q를 사용한다.
vim.keymap.set("n", "<Leader>Q", "<Cmd>SmartQuit<CR>", { silent = true, desc = "Quit (buffer or window)" })
-- 같은 이유로, trouble의 <leader>x* 6개 때문에 <Leader>x도 timeoutlen을 기다린다.
vim.keymap.set("n", "<Leader>X", "<Cmd>SmartExit<CR>", { silent = true, desc = "Save and quit (buffer or window)" })

-- :q / :wq / :x — 파일 창이 하나뿐이면 창이 아니라 버퍼를 닫는다.
-- 판단과 이유는 config/bufdelete.lua의 smart_quit.
for name, write in pairs({ SmartQuit = false, SmartWriteQuit = "write", SmartExit = "update" }) do
  vim.api.nvim_create_user_command(name, function(args)
    require("config.bufdelete").smart_quit({ bang = args.bang, write = write or nil })
  end, { bang = true, desc = "파일 창이 하나뿐이면 버퍼만 닫는 :q / :wq / :x" })
end

-- 내장 명령은 덮어쓸 수 없으므로 명령줄에서 <CR>을 누르는 순간 줄 전체를 보고 바꾼다.
-- 줄이 정확히 q / wq / x(뒤에 !만 허용)일 때만 바꾸고, 나머지는 손대지 않는다:
--   `:q | echo 1`, `:wq 다른이름`, `:w | q`, `:2q`, `:'<,'>x`, `/q` 검색, input() 프롬프트,
--   Ex 모드(gQ).
-- 명령줄 약어(cabbrev)로 하면 안 된다. 약어는 단어 뒤에 공백이나 !를 치는 순간 바뀌어서
-- `:q | …`와 `:wq 파일`이 인자를 받지 않는 Smart* 명령으로 넘어가 E488로 실패했다(실측).
-- noremap 매핑·`:normal!`·vim.cmd("q")가 실행하는 q는 이 키를 거치지 않으므로 내장 동작이다.
-- <NL>(<C-j>)도 명령줄을 실행하는 키라서 같이 건다.
local smart_quit_commands = { q = "SmartQuit", wq = "SmartWriteQuit", x = "SmartExit" }
local function run_cmdline(key)
  return function()
    if vim.fn.getcmdtype() == ":" and vim.fn.mode() == "c" then
      local typed, bang = vim.fn.getcmdline():match("^%s*(%a+)(!?)%s*$")
      local command = typed and smart_quit_commands[typed]
      if command then
        -- <C-u>는 커서 앞만 지운다. 커서를 줄 끝으로 보낸 뒤 지워야 `:q<Home><CR>`처럼
        -- 커서를 옮긴 줄에서 뒤에 남은 글자가 명령 이름에 붙지 않는다(SmartQuitq, E492).
        return "<End><C-u>" .. command .. bang .. "<CR>"
      end
    end
    return key
  end
end
for _, key in ipairs({ "<CR>", "<NL>" }) do
  vim.keymap.set("c", key, run_cmdline(key), {
    expr = true,
    desc = "명령줄 실행 (:q / :wq / :x만이면 Smart* 명령으로)",
  })
end

-- 멀티커서(multicursor.nvim) 키:
-- <C-n>: 커서 아래 단어/선택의 다음 일치에 커서 추가
-- <C-Down>/<C-Up>: 아래/위 줄에 커서 추가 (<C-j>/<C-k>는 창 이동이라 피함)
-- <C-a>(visual): 모든 일치에 커서 추가, <leader>m*: 나머지
-- 자세한 설정은 config/multicursor.lua 참조

-- 오타 방지 명령어
vim.api.nvim_create_user_command("W", "w", {})
-- Q / Wq / WQ는 :q / :wq와 같은 동작이어야 하므로 위의 Smart* 명령으로 보낸다.
vim.api.nvim_create_user_command("Q", "SmartQuit<bang>", { bang = true })
vim.api.nvim_create_user_command("Wq", "SmartWriteQuit<bang>", { bang = true })
vim.api.nvim_create_user_command("WQ", "SmartWriteQuit<bang>", { bang = true })

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
