return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("config.nvim-lint") -- 기존 설정 파일 로드
  end,
  dependencies = {
    -- 필요한 의존성 플러그인이 있다면 여기에 추가
  },
  -- Neovim 0.11 진단 기능 개선 활용
  opts = {
    -- 0.11에서 개선된 진단 기능
    events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    linters_by_ft = {
      -- 파일 타입별 린터 설정은 config/nvim-lint.lua에 저장
    },
    -- 0.11 개선된 가상 텍스트 설정
    virtual_text = true,
    -- 진단 표시 자동 업데이트
    update_in_insert = false,
    -- 프로젝트 로컬 설정 파일 지원
    use_local_config = true,
    -- 최대 진단 수
    max_diagnostics = 100,
    -- 0.11에서 개선된 진단 그룹화
    group_diagnostics = true,
    -- 진단 심각도 정렬
    severity_sort = true,
  },
}
