-- blink.cmp 설정 (nvim-cmp 대체)
--
-- nvim-cmp에서 이전할 때의 결정 사항:
--
-- 1. LuaSnip / cmp_luasnip 제거 → 내장 vim.snippet (snippets.preset = "default")
--    기존 설정에는 커스텀 스니펫도, luasnip.loaders 호출도, snippets/ 디렉토리도 없어서
--    luasnip 소스가 실제로 내놓는 항목이 0개였다. LuaSnip은 LSP 스니펫 전개 엔진
--    역할만 하고 있었고, 그건 0.10+ 내장 vim.snippet이 그대로 대체한다.
--    blink의 기본 snippets 소스는 friendly-snippets를 자동으로 읽으므로 기능이 오히려 늘어난다.
--    커스텀 스니펫이 필요해지면 ~/.config/nvim/snippets/ 에 VSCode 형식으로 넣으면 된다.
--
-- 2. cmp-nvim-lua 소스 제거. lazydev.nvim이 상위 호환이라 중복이었다.
--
-- 3. lspkind 제거. blink 내장 kind_icon 컴포넌트가 같은 일을 한다.
--    기존의 "abbr에 detail 덧붙이기" 커스터마이징도 blink 기본 label 컴포넌트가
--    ctx.label_detail을 이미 append하므로 별도 코드가 필요 없다.
--
-- 4. cmp-cmdline 제거. blink은 cmdline 모드를 내장 지원한다.
--
-- 5. 손버릇(<Tab> 순환, <CR> 확정, <C-d>/<C-f> 문서 스크롤)은 그대로 유지한다.
--
-- 6. 의도적으로 버린 것: nvim-cmp sorting.comparators의 언더스코어 페널티 비교자.
--    blink의 score는 i32 정수다(fuzzy/rust/fuzzy.rs:30, 157에서 frizbee 점수 +
--    frecency + proximity + score_offset을 정수로 합산). 즉 동점이 구조적으로
--    드물다고 볼 근거는 없고, `_foo` 계열 후보의 상대 순위는 기존과 달라질 수 있다.
--    그래도 제거하는 이유는 blink의 fuzzy가 프리픽스/정확도 가중을 이미 하기 때문이며,
--    불편하면 fuzzy.sorts에 비교 함수를 끼워 넣으면 된다.

---@module 'blink.cmp'
---@type blink.cmp.Config
return {
	-- 키 매핑
	-- blink의 "default" 프리셋은 <C-y> 확정이라 기존 손버릇과 달라지므로 preset = "none".
	keymap = {
		preset = "none",

		["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "hide", "fallback" },

		-- 기존 cmp의 <C-d>/<C-f>를 유지한다 (blink 기본은 <C-b>/<C-f>)
		["<C-d>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },

		-- select_and_accept = 선택된 항목, 없으면 첫 항목을 확정.
		-- 기존 cmp의 confirm({ select = true })와 같은 동작이다.
		["<CR>"] = { "select_and_accept", "fallback" },

		-- <Tab>: 메뉴가 떠 있으면 항목 순환, 스니펫 안이면 placeholder 이동, 나머지는 fallback
		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },

		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
	},

	appearance = {
		-- Nerd Font Mono 기준 아이콘 정렬
		nerd_font_variant = "mono",
	},

	completion = {
		list = {
			selection = {
				-- 기존 completeopt의 noselect + confirm({ select = true }) 조합을 재현한다.
				-- 자동 선택하지 않고, <CR>이 첫 항목을 집는다.
				preselect = false,
				-- 탐색만으로 버퍼에 텍스트를 넣지 않는다 (nvim-cmp와 동일한 감각)
				auto_insert = false,
			},
		},

		menu = {
			border = "rounded",
			scrollbar = true,
			winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",

			draw = {
				-- 기존 cmp의 fields = { "kind", "abbr", "menu" } 순서를 그대로 재현.
				-- kind_icon만 쓰면 아이콘만 남는다(text = ctx.kind_icon .. ctx.icon_gap).
				-- 기존 lspkind는 mode = "symbol_text"로 아이콘 + kind 이름을 함께 보여줬으므로
				-- kind 컴포넌트를 같은 열에 붙인다. 아이콘만 원하면 "kind"를 빼면 된다.
				columns = {
					{ "kind_icon", "kind" },
					{ "label", "label_description", gap = 1 },
					{ "source_name" },
				},
				components = {
					label = {
						-- 기존 lspkind maxwidth = 50
						width = { fill = true, max = 50 },
					},
					-- 소스 라벨을 기존 표기([LSP], [Snip] 등)와 같은 대괄호 형태로 감싼다
					source_name = {
						width = { max = 30 },
						text = function(ctx)
							return "[" .. ctx.source_name .. "]"
						end,
						highlight = "BlinkCmpSource",
					},
				},
			},
		},

		documentation = {
			-- nvim-cmp는 문서창을 자동으로 띄웠으므로 동작을 유지한다
			auto_show = true,
			auto_show_delay_ms = 200,
			window = {
				border = "rounded",
				max_width = 60, -- 기존 cmp documentation max_width
				max_height = 15, -- 기존 cmp documentation max_height
				winhighlight = "Normal:Normal,FloatBorder:BorderBG,EndOfBuffer:Normal",
			},
		},

		-- 기존 experimental.ghost_text (하이라이트는 BlinkCmpGhostText → Comment에 링크됨)
		ghost_text = { enabled = true },

		accept = {
			-- auto_brackets는 nvim-cmp 시절에 없던 동작이고 아직 experimental이다.
			-- nvim-autopairs가 이미 괄호를 담당하고 있으므로 기본은 끈다.
			-- 켜보고 싶으면 enabled = true로 바꾸면 된다.
			auto_brackets = { enabled = false },
		},
	},

	-- 시그니처 도움말은 0.11 내장 <C-s>를 계속 쓴다.
	-- blink 쪽을 쓰려면 enabled = true + keymap에 show_signature를 추가할 것.
	signature = { enabled = false },

	snippets = {
		-- 내장 vim.snippet 사용. friendly-snippets는 snippets 소스가 자동으로 읽는다.
		preset = "default",
	},

	sources = {
		-- 주의: default 배열의 순서는 우선순위가 아니다. blink은 fuzzy score에
		-- provider별 score_offset을 더한 정수 점수로 정렬한다
		-- (blink.cmp/lua/blink/cmp/fuzzy/rust/fuzzy.rs:157).
		-- 우선순위는 아래 providers의 score_offset이 결정한다.
		default = { "lazydev", "lsp", "path", "snippets", "buffer" },

		per_filetype = {
			-- 기존 cmp.setup.filetype("gitcommit", ...) — 버퍼 단어만
			gitcommit = { "buffer" },
			-- 기존 cmp.setup.filetype("markdown", ...)
			markdown = { "lsp", "snippets", "path", "buffer" },
		},

		providers = {
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100,
			},
			-- blink 기본 score_offset은 path +3 / lsp 0 이라 동일 품질이면 path가 LSP를
			-- 앞선다. 기존 nvim-cmp는 nvim_lsp 1000 > path 250 이었으므로 LSP를 올려
			-- 그 순서를 되돌린다.
			lsp = { name = "LSP", score_offset = 4 },
			path = { name = "Path" },
			-- snippets는 blink 기본값(provider -1 + 전역 -3 = -4)을 그대로 둔다.
			-- 기존 설정의 luasnip priority 750은 사실상 무의미했다(스니펫 소스가
			-- 항목을 0개 내놓았음). 이제 friendly-snippets가 실제로 항목을 내므로
			-- buffer보다 아래에 두는 blink 기본값이 오히려 덜 시끄럽다.
			snippets = { name = "Snip" },
			cmdline = {
				name = "Cmd",
				-- blink의 cmdline provider는 기본 임계값이 없어 전역 0으로 떨어진다.
				-- 기존 nvim-cmp는 `:`의 cmdline 소스에 keyword_length = 2였으므로 맞춘다.
				-- (이게 없으면 `:` 뒤 한 글자에 200개 후보 메뉴가 바로 뜬다)
				min_keyword_length = 2,
			},
			buffer = {
				name = "Buf",
				-- provider 설정은 모드 간 공유되므로(blink에 per-mode provider 설정이 없다)
				-- 하나의 값으로는 기존 동작을 재현할 수 없었다. 기존 nvim-cmp는
				-- insert buffer 소스 keyword_length = 3, `/`·`?` 검색 buffer 소스는 2였다.
				min_keyword_length = function(ctx)
					return ctx.mode == "cmdline" and 2 or 3
				end,
				opts = {
					-- 성능을 위해 큰 버퍼는 제외한다 (기존 get_bufnrs 로직 이식).
					-- blink 기본값은 "보이는 버퍼만"이지만, 기존 동작은 열려 있는 모든 버퍼였다.
					-- 단 로드되지 않은 버퍼는 제외한다: nvim_buf_get_offset이 -1을 돌려주기 때문에
					-- 기존 코드에서는 크기 검사를 통과해 그냥 포함되고 있었다.
					get_bufnrs = function()
						local bufs = {}
						for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
							if vim.api.nvim_buf_is_loaded(bufnr) then
								local bufsize = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
								if bufsize < 1024 * 1024 then -- 1MB 미만 파일만
									table.insert(bufs, bufnr)
								end
							end
						end
						return bufs
					end,
				},
			},
		},
	},

	cmdline = {
		-- 기존 cmp.setup.cmdline(":" / "/" / "?") 대체.
		-- blink은 모드별 소스를 알아서 고른다(: → cmdline + path, / → buffer).
		-- 기본 프리셋은 <Tab>으로 메뉴를 열고 항목을 넣는 방식이며,
		-- 이는 메뉴가 이미 떠 있을 때 다음 항목 선택으로 동작한다.
		keymap = { preset = "cmdline" },
		completion = {
			-- nvim-cmp는 cmdline 완성을 자동으로 띄웠으므로 동작을 유지한다.
			-- 산만하면 auto_show = false로 되돌릴 수 있다.
			-- 최소 키워드 길이는 위 providers의 cmdline/buffer에서 2자로 맞췄다.
			menu = { auto_show = true },
			ghost_text = { enabled = true },
		},
	},

	fuzzy = {
		-- cargo가 있으므로 소스 빌드된 Rust 매처를 쓴다.
		-- prebuilt 다운로드는 spec 쪽 build = "cargo build --release"로 대체했다.
		implementation = "prefer_rust_with_warning",
		prebuilt_binaries = { download = false },
		sorts = { "exact", "score", "sort_text" },
	},
}
