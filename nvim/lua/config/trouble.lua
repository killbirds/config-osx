-- trouble.nvim v3 설정
-- v2의 position/height/auto_preview/auto_jump/use_diagnostic_signs는
-- v3에서 modes 구조로 이동했다. 각 모드별 옵션은 여기서 정의한다.
local trouble = require("trouble")

trouble.setup({
  modes = {
    diagnostics = {
      win = {
        position = "bottom",
        size = 10,
      },
      auto_preview = true,
      preview = {
        type = "main",
      },
    },
    lsp = {
      win = {
        position = "bottom",
        size = 10,
      },
      auto_preview = true,
      preview = {
        type = "main",
      },
      -- v3의 auto_jump는 boolean: 결과가 1개면 바로 점프.
      -- (v2의 { "lsp_definitions" } 같은 모드 목록 형식은 더 이상 없음)
      auto_jump = true,
    },
    symbols = {
      win = {
        position = "bottom",
        size = 10,
      },
      auto_preview = true,
      preview = {
        type = "main",
      },
    },
  },
})

-- 키 바인딩은 plugins/ui.lua에서 정의됨:
-- <leader>xx: diagnostics toggle
-- <leader>xX: diagnostics toggle (현재 버퍼)
-- <leader>xL: loclist toggle
-- <leader>xQ: qflist toggle
-- <leader>xl: lsp toggle
-- <leader>xs: symbols toggle
