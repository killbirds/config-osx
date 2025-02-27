require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all"
	ensure_installed = { "scala", "typescript", "javascript", "rust", "toml", "python", "html", "css" }, -- 필요한 언어 추가

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Set to false if you want to handle parser installations manually
	auto_install = true,

	-- List of parsers to ignore installing (for "all")
	ignore_install = {}, -- 불필요한 언어는 여기서 제외

	ident = { enable = true },

	highlight = {
		-- Enable/disable tree-sitter highlighting
		enable = true,

		-- List of parsers that will be disabled
		disable = { "lua", "rust" }, -- 기본 하이라이팅을 제외할 언어 추가

		-- Use tree-sitter and syntax highlighting together (may cause performance issues)
		additional_vim_regex_highlighting = false,
	},

	-- Enable incremental selection
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<CR>", -- 시작할 때
			node_incremental = "<CR>", -- 노드 증가
			node_decremental = "<BS>", -- 노드 감소
			scope_incremental = "<C-Space>", -- 범위 증가
		},
	},

	-- Enable folding based on tree-sitter
	folding = {
		enable = true, -- 자동 코드 접기
		disable = { "markdown", "text" }, -- 접기를 원하지 않는 언어
	},
})
