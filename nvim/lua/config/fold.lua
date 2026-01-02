-- 코드 접기 설정
local M = {}

-- 기본 접기 설정
function M.setup()
  -- 접기 방식 설정 (Treesitter 기반)
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

  -- Neovim 0.11에 최적화된 LSP 문서 심볼 기반 폴딩 적용 함수
  local function apply_lsp_folding(buffer, nestingLevel)
    nestingLevel = nestingLevel or 2

    -- 커서 위치 저장
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    -- 0.11 이상에서는 document_fold 함수가 항상 사용 가능
    vim.lsp.buf.document_fold({
      nestingLevel = nestingLevel,
    })

    -- 커서 위치 복원
    vim.api.nvim_win_set_cursor(0, cursor_pos)
    return true
  end

  -- LSP 문서 폴딩 설정 (Neovim 0.11+)
  vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local buffer = args.buf

      -- 언어 서버가 documentSymbol을 지원하는지 확인
      if client and client.server_capabilities.documentSymbolProvider then
        -- LSP 기반 폴딩 키 매핑 추가
        vim.keymap.set("n", "<leader>zl", function()
          apply_lsp_folding(buffer)
          vim.notify("LSP 기반 폴딩이 적용되었습니다.", vim.log.levels.INFO)
        end, { buffer = buffer, noremap = true, desc = "Apply LSP-based folding" })
      end
    end,
  })

  -- 언어별 최적화된 폴딩 설정
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "lua", "python", "rust", "typescript", "javascript", "go" },
    callback = function()
      local ft = vim.bo.filetype

      -- 언어별 중첩 폴딩 수준 최적화
      local nestingLevels = {
        lua = 3,
        python = 2,
        rust = 3,
        typescript = 2,
        javascript = 2,
        go = 2,
      }

      -- 폴딩 키 매핑 재정의 (언어별 최적화)
      vim.keymap.set("n", "<leader>zL", function()
        if vim.lsp.get_clients({ bufnr = 0 })[1] then
          apply_lsp_folding(0, nestingLevels[ft] or 2)
          vim.notify(ft .. " 언어에 최적화된 폴딩이 적용되었습니다.", vim.log.levels.INFO)
        else
          vim.notify("LSP 서버가 준비되지 않았습니다.", vim.log.levels.WARN)
        end
      end, { buffer = 0, noremap = true, desc = "Apply language-optimized folding" })
    end,
  })

  -- 하이브리드 폴딩: LSP + Treesitter 통합
  -- 일부 언어에서는 LSP가 제공하지 않는 세밀한 폴딩을 Treesitter로 보완
  vim.keymap.set("n", "<leader>zh", function()
    -- 현재 LSP 클라이언트 확인
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    local has_lsp_folding = false

    for _, client in ipairs(clients) do
      if client.server_capabilities.documentSymbolProvider then
        has_lsp_folding = true
        break
      end
    end

    -- LSP 폴딩 사용 가능하면 LSP 기반 폴딩 적용, 아니면 Treesitter 폴딩으로 대체
    if has_lsp_folding then
      apply_lsp_folding(0, 2)
      vim.notify("LSP 기반 폴딩이 적용되었습니다.", vim.log.levels.INFO)
    else
      -- Treesitter 폴딩 적용
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
      vim.cmd("normal! zx") -- 폴딩 리프레시
      vim.notify("Treesitter 기반 폴딩이 적용되었습니다.", vim.log.levels.INFO)
    end

    -- 폴딩 활성화
    vim.opt_local.foldenable = true
  end, { noremap = true, desc = "Apply hybrid folding (LSP + Treesitter)" })

  -- 기존 키 매핑
  vim.keymap.set("n", "<leader>z", "za", { noremap = true, desc = "Toggle fold" })
  vim.keymap.set("n", "<leader>Z", "zA", { noremap = true, desc = "Toggle all folds" })
  vim.keymap.set("n", "zR", function()
    vim.opt.foldenable = false
  end, { noremap = true, desc = "Open all folds" })
  vim.keymap.set("n", "zM", function()
    vim.opt.foldenable = true
  end, { noremap = true, desc = "Close all folds" })

  -- 추가 폴딩 유틸리티
  vim.keymap.set("n", "<leader>zn", function()
    -- 현재 함수만 접기
    if pcall(require, "nvim-treesitter.locals") then
      local ts_locals = require("nvim-treesitter.locals")
      local bufnr = vim.api.nvim_get_current_buf()

      -- 현재 커서 위치 가져오기
      local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
      row = row - 1

      -- 함수 위치 찾기
      local root = vim.treesitter.get_parser(bufnr):parse()[1]:root()
      local query = vim.treesitter.query.get(vim.bo.filetype, "locals")

      if not query then
        vim.notify("이 언어에 대한 Treesitter 쿼리를 찾을 수 없습니다.", vim.log.levels.WARN)
        return
      end

      for _, node, _ in query:iter_captures(root, bufnr, 0, -1) do
        local node_type = node:type()
        if
            node_type == "function"
            or node_type == "method"
            or node_type:match("function")
            or node_type:match("method")
        then
          local start_row, _, end_row, _ = node:range()

          -- 현재 커서가 함수 내에 있는지 확인
          if row >= start_row and row <= end_row then
            -- 함수 폴딩
            vim.api.nvim_win_set_cursor(0, { start_row + 1, 0 })
            vim.cmd("normal! za")
            return
          end
        end
      end

      vim.notify("현재 커서 위치에서 함수를 찾을 수 없습니다.", vim.log.levels.INFO)
    else
      vim.notify("이 기능을 사용하려면 nvim-treesitter가 필요합니다.", vim.log.levels.WARN)
    end
  end, { noremap = true, desc = "Fold current function only" })
end

return M
