local cmp = require("cmp")
local lspkind = require("lspkind")
local luasnip = require("luasnip")

-- 자동완성 옵션 설정 (전역 설정)
vim.opt.completeopt = { "menu", "menuone", "noselect" }

cmp.setup({
  -- 스니펫 확장 설정
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body) -- LuaSnip으로 스니펫 확장
    end,
  },
  -- 창 스타일 설정
  window = {
    completion = cmp.config.window.bordered({
      border = "rounded", -- 둥근 테두리
      winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel",
      scrollbar = true, -- 스크롤바 표시
    }),
    documentation = cmp.config.window.bordered({
      border = "rounded",
      winhighlight = "Normal:Normal,FloatBorder:BorderBG",
      max_height = 15, -- 문서창 최대 높이 제한
      max_width = 60, -- 문서창 최대 너비 제한
    }),
  },
  -- 키 매핑 설정
  mapping = cmp.mapping.preset.insert({
    ["<C-d>"] = cmp.mapping.scroll_docs(-4), -- 문서 스크롤 업
    ["<C-f>"] = cmp.mapping.scroll_docs(4), -- 문서 스크롤 다운
    ["<C-Space>"] = cmp.mapping.complete(), -- 수동 완성 트리거
    ["<C-e>"] = cmp.mapping.abort(),       -- 완성 창 닫기
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace, -- 선택 항목으로 교체
      select = true,                       -- 첫 번째 항목 자동 선택
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump() -- 스니펫 확장 또는 점프
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1) -- 이전 스니펫 위치로 이동
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  -- 자동완성 소스 설정 (우선순위 순)
  sources = cmp.config.sources({
    { name = "nvim_lsp", priority = 1000 }, -- LSP 소스 (최우선)
    { name = "luasnip",  priority = 750 }, -- LuaSnip 스니펫
    { name = "nvim_lua", priority = 500 }, -- Neovim Lua API
    { name = "path",     priority = 250 }, -- 파일 경로
  }, {
    {
      name = "buffer",
      priority = 100,
      keyword_length = 3, -- 키워드 최소 길이
      option = {
        get_bufnrs = function()
          -- 현재 버퍼와 큰 파일이 아닌 버퍼만 포함 (성능 향상)
          local bufs = {}
          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            local bufsize = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
            if bufsize < 1024 * 1024 then -- 1MB 미만 파일만
              table.insert(bufs, bufnr)
            end
          end
          return bufs
        end,
      },
    },
  }),
  -- 정렬 설정 추가
  sorting = {
    priority_weight = 2.0, -- 우선순위 가중치
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      -- 함수 인자 우선 정렬 (함수 호출 시 유용)
      function(entry1, entry2)
        local _, entry1_under = entry1.completion_item.label:find("^_+")
        local _, entry2_under = entry2.completion_item.label:find("^_+")
        entry1_under = entry1_under or 0
        entry2_under = entry2_under or 0
        if entry1_under > entry2_under then
          return false
        elseif entry1_under < entry2_under then
          return true
        end
      end,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  -- 항목 포맷팅 설정
  formatting = {
    fields = { "kind", "abbr", "menu" }, -- 표시 순서: 아이콘, 텍스트, 메뉴
    format = lspkind.cmp_format({
      mode = "symbol_text",            -- 아이콘 + 텍스트 표시
      maxwidth = 50,                   -- 최대 너비 제한
      ellipsis_char = "...",           -- 잘릴 경우 생략 기호
      menu = {                         -- 소스별 레이블 커스터마이징
        nvim_lsp = "[LSP]",
        luasnip = "[Snip]",
        nvim_lua = "[Lua]",
        path = "[Path]",
        buffer = "[Buf]",
        calc = "[Calc]",
        emoji = "[Emoji]",
        treesitter = "[TS]",
      },
      before = function(entry, vim_item)
        -- 함수 호출에서 인자 이름 표시
        if entry.completion_item.detail then
          vim_item.menu = entry.completion_item.detail
        end
        return vim_item
      end,
    }),
  },
  -- 실험적 기능
  experimental = {
    ghost_text = { hl_group = "Comment" }, -- 입력 중 미리보기 (스타일 지정)
    native_menu = false,                 -- 네이티브 메뉴 비활성화
  },
  -- 완성 확인 이벤트 핸들러 추가
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace, -- 선택 항목으로 교체
    select = true,                        -- 첫 번째 항목 자동 선택
  },
  -- 완성 항목이 하나만 있을 때 자동 선택
  preselect = cmp.PreselectMode.Item,
})

-- 파일 타입별 추가 설정
cmp.setup.filetype("gitcommit", {
  sources = cmp.config.sources({
    { name = "cmp_git" }, -- Git 관련 자동완성 (설치 필요)
  }, {
    { name = "buffer" },
  }),
})

-- 마크다운 파일 설정 추가
cmp.setup.filetype("markdown", {
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "emoji",   option = { insert = true } }, -- 이모지 지원 (cmp-emoji 필요)
  }, {
    { name = "buffer" },
  }),
})

-- 검색 명령어 자동완성
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer", keyword_length = 2 }, -- 버퍼 기반 검색 완성
  },
})

-- 명령어 모드 자동완성
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },                      -- 경로 완성
  }, {
    { name = "cmdline", keyword_length = 2 }, -- Neovim 명령어 완성
  }),
})

-- 자동완성 나타날 때 커서 줄 강조 숨기기 (선택 사항)
vim.api.nvim_create_autocmd("CmdwinEnter", {
  callback = function()
    vim.opt_local.cursorline = false
  end,
})
