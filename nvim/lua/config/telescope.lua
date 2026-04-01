local actions = require("telescope.actions")
local telescope = require("telescope")

local function open_with_trouble(prompt_bufnr)
  local ok, trouble_telescope = pcall(require, "trouble.sources.telescope")
  if ok then
    return trouble_telescope.open(prompt_bufnr)
  end

  return actions.select_default(prompt_bufnr)
end

telescope.setup({
  defaults = {
    file_ignore_patterns = { "node_modules", ".git", "yarn.lock", "\\.cache" },
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-h>"] = actions.which_key,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-o>"] = actions.select_default,
        ["<C-t>"] = open_with_trouble,
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,
      },
      n = {
        ["<C-t>"] = open_with_trouble,
      },
    },
    history = {
      path = vim.fn.stdpath("data") .. "/telescope_history.sqlite3",
      limit = 100,
    },
    cache_picker = {
      num_pickers = 10,
      limit = 100,
    },
  },
  pickers = {
    find_files = {
      -- theme = "dropdown",
      -- find_command = { "ag", "-l", "--nocolor", "--hidden", "-g", "" },
    },
    buffers = {
      sort_mru = true,
      ignore_current_buffer = true,
    },
    live_grep = {
      -- 기본 설정 유지
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({
        -- 추가 설정을 여기에 넣을 수 있습니다
        width = 0.8,
        previewer = false,
      }),
    },
  },
})

-- Load fzf extension
telescope.load_extension("fzf")

-- Load ui-select extension
telescope.load_extension("ui-select")

-- Load smart-history extension
telescope.load_extension("smart_history")

-- Load projects
telescope.load_extension("projects")
