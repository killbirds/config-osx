local M = {}

-- 공통 키맵 설정 함수
local function set_keymap(bufnr, mode, lhs, rhs, desc)
  local opts = { noremap = true, silent = true, buffer = bufnr, desc = desc }
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- 공통 LSP 설정을 적용하는 함수
local function setup_buffer_options(bufnr)
  -- 오므니펑션 설정 (LSP 기반 자동완성)
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
  -- 버퍼별 추가 옵션 (선택적)
  vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
end

-- Inlay Hints 키 매핑 설정 함수
local function setup_inlay_hints_keymaps(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  -- Inlay hints 토글 키 매핑 (API 문서 기반 수정)
  vim.keymap.set("n", "<leader>th", function()
    -- 현재 버퍼에서만 토글
    local current_bufnr = vim.api.nvim_get_current_buf()
    local filter = { bufnr = current_bufnr }
    local enabled = vim.lsp.inlay_hint.is_enabled(filter)
    vim.lsp.inlay_hint.enable(not enabled, filter)
  end, vim.tbl_extend("force", opts, { desc = "Toggle Inlay Hints" }))
end

-- on_attach 함수: LSP 클라이언트가 버퍼에 연결될 때 호출
M.on_attach = function(client, bufnr)
  -- 버퍼 옵션 설정
  setup_buffer_options(bufnr)

  -- LSP 기본 키바인딩
  set_keymap(bufnr, "n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
  set_keymap(bufnr, "n", "gd", vim.lsp.buf.definition, "Go to Definition")
  set_keymap(bufnr, "n", "K", vim.lsp.buf.hover, "Show Hover Documentation")
  set_keymap(bufnr, "n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
  set_keymap(bufnr, "n", "gy", vim.lsp.buf.type_definition, "Go to Type Definition")
  set_keymap(bufnr, "n", "gr", vim.lsp.buf.references, "List References")

  -- 워크스페이스 관련 키맵
  set_keymap(bufnr, "n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
  set_keymap(bufnr, "n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
  set_keymap(bufnr, "n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "List Workspace Folders")

  -- 코드 조작 관련 키맵
  set_keymap(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
  set_keymap(bufnr, "n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

  -- 진단 관련 키맵은 config/diagnostics.lua에서 중앙 관리됨
  -- 중복 방지를 위해 여기서는 제거

  -- 서버별 조건부 설정 (예시)
  if client:supports_method("textDocument/formatting") then
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
      vim.lsp.buf.format({ async = true })
    end, { desc = "Format current buffer with LSP" })
  end

  -- Inlay Hints 키 매핑 설정 (최신 Neovim 버전 확인)
  if vim.lsp.inlay_hint and vim.fn.has("nvim-0.10.0") == 1 then
    setup_inlay_hints_keymaps(bufnr)
  end

  -- LSP 관리 키 매핑 추가
  local opts = { noremap = true, silent = true }
  vim.keymap.set("n", "<leader>lc", "<cmd>LspCleanup<cr>",
    vim.tbl_extend("force", opts, { desc = "LSP 중복 클라이언트 정리" }))
  vim.keymap.set("n", "<leader>ls", "<cmd>LspStatus<cr>",
    vim.tbl_extend("force", opts, { desc = "LSP 상태 확인" }))
  vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<cr>",
    vim.tbl_extend("force", opts, { desc = "LSP 재시작" }))
end

-- 추가 유틸리티 함수 (선택적)
M.setup = function()
  -- 진단 설정은 config/diagnostics.lua에서 중앙 관리됨
end

return M
