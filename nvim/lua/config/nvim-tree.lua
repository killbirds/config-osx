local function on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- Default mappings. Feel free to modify or remove as you wish.
  --
  -- BEGIN_DEFAULT_ON_ATTACH
  vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
  vim.keymap.set("n", "<C-e>", api.node.open.replace_tree_buffer, opts("Open: In Place"))
  vim.keymap.set("n", "<C-k>", api.node.show_info_popup, opts("Info"))
  vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
  vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts("Open: Vertical Split"))
  vim.keymap.set("n", "<C-x>", api.node.open.horizontal, opts("Open: Horizontal Split"))
  vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
  vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
  vim.keymap.set("n", "<Tab>", api.node.open.preview, opts("Open Preview"))
  vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
  vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
  vim.keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))
  vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("Up"))
  vim.keymap.set("n", "a", api.fs.create, opts("Create"))
  vim.keymap.set("n", "bmv", api.marks.bulk.move, opts("Move Bookmarked"))
  vim.keymap.set("n", "B", api.tree.toggle_no_buffer_filter, opts("Toggle No Buffer"))
  vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
  vim.keymap.set("n", "C", api.tree.toggle_git_clean_filter, opts("Toggle Git Clean"))
  vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
  vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("Next Git"))
  vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
  vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
  vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
  vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
  vim.keymap.set("n", "]e", api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
  vim.keymap.set("n", "[e", api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
  vim.keymap.set("n", "F", api.live_filter.clear, opts("Clean Filter"))
  vim.keymap.set("n", "f", api.live_filter.start, opts("Filter"))
  vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
  vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
  vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
  vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Git Ignore"))
  vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
  vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))
  vim.keymap.set("n", "m", api.marks.toggle, opts("Toggle Bookmark"))
  vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
  vim.keymap.set("n", "O", api.node.open.no_window_picker, opts("Open: No Window Picker"))
  vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
  vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
  vim.keymap.set("n", "q", api.tree.close, opts("Close"))
  vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
  vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
  vim.keymap.set("n", "s", api.node.run.system, opts("Run System"))
  vim.keymap.set("n", "S", api.tree.search_node, opts("Search"))
  vim.keymap.set("n", "U", api.tree.toggle_custom_filter, opts("Toggle Hidden"))
  vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse"))
  vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
  vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))
  vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("Copy Relative Path"))
  vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
  vim.keymap.set("n", "<2-RightMouse>", api.tree.change_root_to_node, opts("CD"))
  -- END_DEFAULT_ON_ATTACH

  -- Custom mappings
  vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts("Up"))
  vim.keymap.set("n", "<C-r>", api.tree.reload, opts("Refresh"))
end

-- 하이라이트 그룹 정의
local function setup_nvim_tree_highlights()
  vim.api.nvim_set_hl(0, "NvimTreeGitDirty", { fg = "#f1c40f" })  -- 변경된 파일 (노란색)
  vim.api.nvim_set_hl(0, "NvimTreeGitStaged", { fg = "#2ecc71" }) -- 스테이징된 파일 (녹색)
  vim.api.nvim_set_hl(0, "NvimTreeGitMerge", { fg = "#3498db" })  -- 머지 충돌 (파란색)
  vim.api.nvim_set_hl(0, "NvimTreeGitRenamed", { fg = "#e67e22" }) -- 이름 변경 (주황색)
  vim.api.nvim_set_hl(0, "NvimTreeGitNew", { fg = "#95a5a6" })    -- 새 파일 (회색)
  vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", { fg = "#e74c3c" }) -- 삭제된 파일 (빨간색)
end

-- 하이라이트 설정 적용
setup_nvim_tree_highlights()

-- 컬러 스키마 변경 시 하이라이트 다시 적용
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    setup_nvim_tree_highlights()
  end,
})

require("nvim-tree").setup({
  sort_by = "name",
  update_cwd = false,
  filesystem_watchers = {
    enable = false,
  },
  view = {
    adaptive_size = true,
    width = 30,
    side = "left",
    signcolumn = "yes",
  },
  renderer = {
    group_empty = true,
    highlight_git = true,
    full_name = false,
    root_folder_label = ":~:s?$?/..?",
    indent_width = 2,
    indent_markers = {
      enable = false,
      inline_arrows = true,
    },
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
    special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
  },
  filters = {
    dotfiles = false,
    custom = { "node_modules", "\\.git", "^target$", "\\.DS_Store", "\\.cache" },
    exclude = {},
  },
  git = {
    enable = true,
    ignore = false,
    show_on_dirs = true,
    timeout = 100,
  },
  actions = {
    change_dir = {
      restrict_above_cwd = true,
    },
    open_file = {
      quit_on_open = false,
      resize_window = true,
      window_picker = {
        enable = false,
      },
    },
  },
  on_attach = on_attach,
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
})

-- Keymap for toggling nvim-tree
vim.keymap.set("n", "<F2>", function()
  return require("nvim-tree.api").tree.toggle({ focus = true })
end, { silent = true, desc = "toggle nvim-tree" })

-- Keymap for finding file in nvim-tree
vim.keymap.set("n", "<F3>", function()
  require("nvim-tree.api").tree.find_file({ open = true, focus = true })
end, { silent = true, desc = "find_file nvim-tree" })

-- 추가 유용한 키 매핑
vim.keymap.set("n", "<leader>tr", function()
  require("nvim-tree.api").tree.reload()
end, { silent = true, desc = "Reload nvim-tree" })

vim.keymap.set("n", "<leader>tf", function()
  local view = require("nvim-tree.view")
  if view.is_visible() then
    view.focus()
  else
    require("nvim-tree.api").tree.open({ find_file = true })
  end
end, { silent = true, desc = "Focus or Open nvim-tree with current file" })

-- Open nvim-tree at startup
local function open_nvim_tree(data)
  -- 버퍼가 디렉토리인 경우에만 열기
  local directory = vim.fn.isdirectory(data.file) == 1

  -- 인자가 없는 경우 (일반적인 neovim 시작)
  local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

  if directory or no_name then
    -- 디렉토리를 열 때는 현재 디렉토리를 루트로 설정
    if directory then
      vim.cmd.cd(data.file)
    end

    -- nvim-tree 열기
    require("nvim-tree.api").tree.open()
  end
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
