-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3

return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = true,
  version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
  opts = function()
    -- API 키 관리 개선 - 보안 강화
    local function get_api_key(env_var, config_path)
      -- 1. 환경 변수에서 먼저 확인
      local key = vim.env[env_var]
      if key and key ~= "" then
        return key
      end

      -- 2. 설정 파일에서 확인 (더 안전한 방식)
      local config_file = vim.fn.expand(config_path)
      if vim.fn.filereadable(config_file) == 1 then
        local content = vim.fn.readfile(config_file)
        if content and #content > 0 then
          return content[1]:gsub("%s+", "")
        end
      end

      return nil
    end

    local api_keys = {
      openai = get_api_key("OPENAI_API_KEY", "~/.config/nvim/openai_key"),
      anthropic = get_api_key("ANTHROPIC_API_KEY", "~/.config/nvim/anthropic_key"),
    }

    local provider = vim.env.NVIM_AVANTE_PROVIDER or "openai"

    return {
      -- 기본 제공자 설정
      provider = provider, -- 기본 AI 제공자

      -- 다양한 AI 모델 설정
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "o1-mini", -- 기본 모델
        models = {         -- 선택 가능한 모델 목록
          { name = "o1", label = "GPT-o1 (최고 성능)" },
          { name = "o1-mini", label = "GPT-o1-mini (표준)" },
        },
        timeout = 60000,   -- 타임아웃 시간 증가 (60초)
        temperature = 0,   -- 정확한 응답을 위한 낮은 온도
        max_tokens = 8192, -- 토큰 한도 증가
        retry_count = 3,   -- 실패 시 재시도 횟수
        api_key = api_keys.openai,
      },

      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-7-sonnet-20250219",
        models = {
          { name = "claude-3-7-sonnet-20250219", label = "Claude 3.7 Sonnet" },
          { name = "claude-3-5-sonnet-20241022", label = "Claude 3.5 Sonnet" },
          { name = "claude-3-opus-20240229",     label = "Claude 3 Opus" },
        },
        temperature = 0,
        max_tokens = 8192,
        api_key = api_keys.anthropic,
      },

      copilot = {
        temperature = 0,
        max_tokens = 8192,
        enabled = true,
      },

      file_selector = {
        type = "telescope",
        options = {
          previewer = true,
          layout_config = {
            width = 0.8,
            height = 0.8,
          },
        },
      },

      -- 에디터 설정
      editor = {
        buffer_height_ratio = 0.6,  -- 버퍼 높이 비율
        scroll_speed = 3,           -- 스크롤 속도
        highlight_selection = true, -- 선택 영역 강조
      },

      -- 기능 토글 설정
      features = {
        auto_completion = true,           -- 자동 완성 활성화
        syntax_highlighting = true,       -- 구문 강조 활성화
        markdown_rendering = true,        -- 마크다운 렌더링
        code_actions = true,              -- 코드 액션 활성화
        image_support = true,             -- 이미지 지원 활성화
        backdrop = true,                  -- Neovim 0.11 backdrop 사용 활성화
        floating_window_centering = true, -- 0.11 부동 창 중앙 정렬 개선
      },

      -- 키매핑 설정
      keymaps = {
        toggle_chat = "<leader>aa",     -- 채팅창 토글
        send_query = "<C-CR>",          -- 쿼리 전송
        cancel_request = "<C-c>",       -- 요청 취소
        insert_response = "<leader>ai", -- 응답 삽입
        toggle_diff = "<leader>ad",     -- 차이점 토글
      },

      -- UI 설정 (0.11 최적화)
      ui = {
        border = "rounded",        -- 둥근 테두리
        width = 0.8,               -- 너비 비율
        height = 0.8,              -- 높이 비율
        zindex = 50,               -- z-index
        show_prompt_prefix = true, -- 프롬프트 접두사 표시
        icons = {
          spinner = "dots",        -- 로딩 스피너 스타일
        },
        theme = "auto",            -- 자동 테마
        backdrop = 80,             -- 0.11 backdrop 투명도 (0-100)
        statuscolumn = true,       -- 0.11 statuscolumn 지원 활성화
      },

      -- Neovim 0.11 특정 최적화
      nvim_0_11 = {
        enabled = vim.fn.has("nvim-0.11") == 1,
        floating_centering = true,       -- 0.11의 개선된 부동 창 중앙 정렬 활용
        backdrop_blur = true,            -- 0.11에서 지원되는 배경 블러 효과
        statuscolumn_integration = true, -- statuscolumn과 통합
      },
    }
  end,
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",

    -- 파일 선택기
    { "echasnovski/mini.pick",         optional = true },  -- 선택적 의존성
    { "nvim-telescope/telescope.nvim", optional = false }, -- 필수 의존성
    { "ibhagwan/fzf-lua",              optional = true },  -- 선택적 의존성

    -- 자동완성 및 아이콘
    "hrsh7th/nvim-cmp", -- avante 명령 및 멘션 자동완성
    "nvim-tree/nvim-web-devicons",

    -- AI 통합
    { "zbirenbaum/copilot.lua", optional = false }, -- Copilot을 필수 의존성으로 변경

    -- 이미지 지원
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          dir_path = vim.fn.expand("~/.cache/avante/images"), -- 이미지 저장 경로
          drag_and_drop = {
            insert_mode = true,
            normal_mode = true,                         -- 노멀 모드에서도 사용 가능
          },
          use_absolute_path = vim.fn.has("win32") == 1, -- Windows에서만 절대 경로 사용
          relative_template = "![](${path})",           -- 마크다운 상대 경로 템플릿
        },
        filetypes = {
          Avante = {}, -- Avante 파일 타입 지원
          markdown = {},
        },
      },
    },
  },

  -- 플러그인 로드 후 추가 설정
  config = function(_, opts)
    -- 플러그인 기본 설정 적용
    require("avante").setup(opts)

    -- 사용자 정의 명령어 추가
    vim.api.nvim_create_user_command("AvanteToggle", function()
      require("avante").toggle()
    end, { desc = "Toggle Avante Chat" })

    vim.api.nvim_create_user_command("AvanteSetModel", function(args)
      require("avante").set_model(args.args)
    end, {
      nargs = 1,
      desc = "Set Avante AI Model",
      complete = function()
        local models = {}
        for _, model in ipairs(opts.openai.models or {}) do
          table.insert(models, model.name)
        end
        for _, model in ipairs(opts.claude.models or {}) do
          table.insert(models, model.name)
        end
        return table.concat(models, "\n")
      end,
    })

    -- API 키 설정 명령어 추가 (0.11 UI 개선 활용)
    vim.api.nvim_create_user_command("AvanteSetApiKey", function(args)
      if not args.args or args.args == "" then
        vim.notify("사용법: AvanteSetApiKey [openai|anthropic]", vim.log.levels.ERROR)
        return
      end

      local provider = args.args
      if provider ~= "openai" and provider ~= "anthropic" then
        vim.notify("지원되는 제공자: openai, anthropic", vim.log.levels.ERROR)
        return
      end

      -- 0.11 개선된 입력 UI 사용
      vim.ui.input({
        prompt = provider .. " API 키를 입력하세요: ",
        default = "",
        completion = "",
        hide_text = true, -- 0.11 비밀번호 숨김 기능
      }, function(key)
        if not key or key == "" then
          return
        end

        -- 키를 파일에 저장
        local config_file = vim.fn.expand("~/.config/nvim/" .. provider .. "_key")
        vim.fn.writefile({ key }, config_file)
        vim.fn.system("chmod 600 " .. config_file) -- 권한 설정
        vim.notify(provider .. " API 키가 성공적으로 설정되었습니다.", vim.log.levels.INFO)

        -- Avante 다시 로드
        require("avante").reload()
      end)
    end, {
      nargs = 1,
      desc = "Set API Key for Avante",
      complete = function()
        return "openai\nanthropic"
      end,
    })

    -- 추가 키매핑
    vim.keymap.set("n", opts.keymaps.toggle_chat, function()
      require("avante").toggle()
    end, { desc = "Toggle Avante Chat" })

    -- 버퍼 자동 명령어
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "Avante",
      callback = function()
        -- Avante 버퍼에서 특정 설정 적용
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = false
        vim.opt_local.conceallevel = 2
      end,
    })
  end,
}
