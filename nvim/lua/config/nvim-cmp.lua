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
		}),
		documentation = cmp.config.window.bordered({
			border = "rounded",
			winhighlight = "Normal:Normal,FloatBorder:BorderBG",
		}),
	},
	-- 키 매핑 설정
	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping.scroll_docs(-4), -- 문서 스크롤 업
		["<C-f>"] = cmp.mapping.scroll_docs(4), -- 문서 스크롤 다운
		["<C-Space>"] = cmp.mapping.complete(), -- 수동 완성 트리거
		["<C-e>"] = cmp.mapping.abort(), -- 완성 창 닫기
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace, -- 선택 항목으로 교체
			select = true, -- 첫 번째 항목 자동 선택
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
		{ name = "luasnip", priority = 750 }, -- LuaSnip 스니펫
		{ name = "nvim_lua", priority = 500 }, -- Neovim Lua API
		{ name = "path", priority = 250 }, -- 파일 경로
	}, {
		{
			name = "buffer",
			priority = 100,
			keyword_length = 3, -- 키워드 최소 길이
			option = {
				get_bufnrs = function()
					return vim.api.nvim_list_bufs()
				end,
			}, -- 모든 버퍼에서 가져오기
		},
	}),
	-- 항목 포맷팅 설정
	formatting = {
		fields = { "kind", "abbr", "menu" }, -- 표시 순서: 아이콘, 텍스트, 메뉴
		format = lspkind.cmp_format({
			mode = "symbol_text", -- 아이콘 + 텍스트 표시
			maxwidth = 50, -- 최대 너비 제한
			ellipsis_char = "...", -- 잘릴 경우 생략 기호
			menu = { -- 소스별 레이블 커스터마이징
				nvim_lsp = "[LSP]",
				luasnip = "[Snip]",
				nvim_lua = "[Lua]",
				path = "[Path]",
				buffer = "[Buf]",
			},
		}),
	},
	-- 실험적 기능 (선택적)
	experimental = {
		ghost_text = true, -- 입력 중 실시간 미리보기 (Neovim 0.6+)
	},
})

-- 파일 타입별 추가 설정
cmp.setup.filetype("gitcommit", {
	sources = cmp.config.sources({
		{ name = "cmp_git" }, -- Git 관련 자동완성 (설치 필요)
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
		{ name = "path" }, -- 경로 완성
	}, {
		{ name = "cmdline", keyword_length = 2 }, -- Neovim 명령어 완성
	}),
})
