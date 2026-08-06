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
  if vim.bo[bufnr].filetype == "java" then
    vim.bo[bufnr].formatexpr = ""
    return
  end

  vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
end

local function show_hover()
  vim.lsp.buf.hover({
    border = "rounded",
    max_width = 80,
    max_height = 20,
  })
end

local function show_signature_help()
  vim.lsp.buf.signature_help({
    border = "rounded",
    max_width = 80,
    max_height = 15,
  })
end

-- on_attach 함수: LSP 클라이언트가 버퍼에 연결될 때 호출
M.on_attach = function(client, bufnr)
  -- 버퍼 옵션 설정
  setup_buffer_options(bufnr)

  -- LSP 기본 키바인딩
  -- gr(references)/gi(implementation) 커스텀 매핑은 제거함.
  -- gr은 0.11 기본 gr* 매핑(grr/grn/gri/gra)과 접두사가 겹쳐 timeoutlen 대기를
  -- 만들었고, gi는 내장 gi(마지막 삽입 위치에서 삽입 모드 진입)를 가렸다.
  -- references는 grr, implementation은 gri(기본 매핑)를 사용한다.
  set_keymap(bufnr, "n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
  set_keymap(bufnr, "n", "gd", vim.lsp.buf.definition, "Go to Definition")
  set_keymap(bufnr, "n", "K", show_hover, "Show Hover Documentation")
  set_keymap(bufnr, "n", "gy", vim.lsp.buf.type_definition, "Go to Type Definition")

  -- 워크스페이스 관련 키맵
  -- <leader>w는 저장(:w) 키이므로 timeout 지연을 피하기 위해 <leader>L 네임스페이스 사용
  set_keymap(bufnr, "n", "<leader>La", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
  set_keymap(bufnr, "n", "<leader>Ld", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
  set_keymap(bufnr, "n", "<leader>Ll", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "List Workspace Folders")

  -- 코드 조작 관련 키맵
  set_keymap(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
  set_keymap(bufnr, "n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  set_keymap(bufnr, { "i", "s" }, "<C-S>", show_signature_help, "Show Signature Help")

  -- 진단 관련 키맵은 config/diagnostics.lua에서 중앙 관리됨
  -- 중복 방지를 위해 여기서는 제거

  -- Inlay Hints 토글 키맵(<leader>th)은 plugins/lsp.lua의 lazy keys에서 정의됨

  -- 서버별 조건부 설정 (예시)
  -- 주의: 이 명령을 "Format"으로 두면 안 된다.
  -- config/conform.lua가 전역 :Format(범위 지원, formatters_by_ft 경유)을 만드는데,
  -- 버퍼 로컬 명령이 전역을 가려서 LSP가 붙은 버퍼에서는 :Format이 conform을
  -- 우회하고 raw LSP 포맷으로 갔다(prettier/stylua/ruff/rustfmt 설정 무시).
  -- 버퍼 로컬 쪽에는 range가 없어 `1,2Format`도 E481로 실패했다.
  -- LSP 직접 포맷은 :LspFormat으로 분리한다.
  if client:supports_method("textDocument/formatting") and vim.bo[bufnr].filetype ~= "java" then
    vim.api.nvim_buf_create_user_command(bufnr, "LspFormat", function()
      vim.lsp.buf.format({ async = true })
    end, { desc = "Format current buffer with LSP (conform 우회)" })
  end

  -- LSP 관리 키맵(<leader>Lc/Ls/Lr)은 전역이므로 config/nvim-lspconfig.lua에서
  -- 한 번만 등록한다. (이전에는 on_attach마다 전역 매핑을 재등록했음)
end

-- 추가 유틸리티 함수 (선택적)
M.setup = function()
  -- 진단 설정은 config/diagnostics.lua에서 중앙 관리됨
end

return M
