local trouble = require("trouble")

-- trouble.nvim 기본 설정
trouble.setup({
  position = "bottom",
  height = 10,
  fold_open = "",
  fold_closed = "",
  indent_lines = true,
  auto_preview = true,
  auto_fold = false,
  auto_jump = { "lsp_definitions" },
  use_diagnostic_signs = false,
})

-- Telescope 통합을 위한 설정은 config/telescope.lua에 있습니다
-- local open_with_trouble = require("trouble.sources.telescope").open

-- 유용한 키 바인딩은 이미 plugin 설정에 정의되어 있습니다:
-- { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "진단 목록 표시" }
-- { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "현재 버퍼 진단 목록" }
-- { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "로케이션 리스트" }
-- { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "퀵픽스 리스트" }
-- { "<leader>xl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP 참조/정의/구현" }
-- { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "문서 심볼" }

-- 추가적인 trouble.nvim 커스텀 설정을 여기에 추가할 수 있습니다
