local function on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buf = bufnr, noremap = true, silent = true, nowait = true }
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
  vim.keymap.set("n", "B", api.filter.no_buffer.toggle, opts("Toggle No Buffer"))
  vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
  vim.keymap.set("n", "C", api.filter.git.clean.toggle, opts("Toggle Git Clean"))
  vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
  vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("Next Git"))
  vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
  vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
  vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
  vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
  vim.keymap.set("n", "]e", api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
  vim.keymap.set("n", "[e", api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
  vim.keymap.set("n", "F", api.filter.live.clear, opts("Clean Filter"))
  vim.keymap.set("n", "f", api.filter.live.start, opts("Filter"))
  vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
  vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
  vim.keymap.set("n", "H", api.filter.dotfiles.toggle, opts("Toggle Dotfiles"))
  vim.keymap.set("n", "I", api.filter.git.ignored.toggle, opts("Toggle Git Ignore"))
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
  vim.keymap.set("n", "U", api.filter.custom.toggle, opts("Toggle Hidden"))
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

-- git 상태 색(NvimTreeGit*)은 plugins/theme.lua의 custom_highlights가 catppuccin 팔레트로 정한다.
-- 예전에는 여기서 Flat UI 색을 하드코딩하고 ColorScheme마다 다시 덮어썼다.

-- 트리 폭의 상한: 화면의 35%, 적어도 30칸.
local function max_tree_width()
  return math.max(30, math.floor(vim.o.columns * 0.35))
end

-- 화면이 좁아지면 열려 있는 트리를 상한까지 줄인다. 상한(아래 view.width.max)은 트리를 그릴
-- 때만 계산되고 트리 창은 winfixwidth라서, 넓을 때 연 트리는 pane이 좁아져도 그 폭으로 남는다
-- (실측: 160칸에서 56칸이던 트리가 60칸으로 줄인 뒤에도 56칸, 편집 창 3칸).
-- Herdr에서는 pane을 나누고 합칠 때마다 nvim의 화면 크기가 바뀐다.
--
-- 하는 일은 상한을 넘은 트리 창의 폭을 상한으로 맞추는 것뿐이다. nvim-tree의 resize()를 쓰면
-- 안 된다. 폭을 매번 최솟값(30)으로 되돌리고 `wincmd =`까지 실행해서, 화면 높이만 바뀌어도 손으로
-- 맞춘 트리 폭과 다른 분할 창들의 비율이 사라졌다(실측: 56/20/82 -> 30/64/64).
-- 다시 넓어진 화면에서 트리를 넓히는 일은 하지 않는다. 다음에 트리를 그릴 때 nvim-tree가 한다.
local resized_at = vim.o.columns
vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("NvimTreeFitWidth", { clear = true }),
  callback = function()
    if vim.o.columns == resized_at then
      return -- 높이만 바뀌었다
    end
    resized_at = vim.o.columns
    local limit = max_tree_width()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if
        vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree"
        and vim.api.nvim_win_get_config(win).relative == ""
        and vim.api.nvim_win_get_width(win) > limit
      then
        vim.api.nvim_win_set_width(win, limit)
      end
    end
  end,
})

require("nvim-tree").setup({
  sort_by = "name",
  update_cwd = false,
  -- 끈 채로 둔다. 켜면 밖에서 만든 파일이 트리에 바로 나타나지만, 트리에 보이는 디렉토리마다
  -- 감시가 하나씩 붙고 이벤트 하나가 그 디렉토리의 `git status`를 따로 실행한다. 디렉토리끼리는
  -- 묶이지 않는다. 실측(파일 12,000개 레포, 디렉토리 200개가 보이는 트리): 감시 204개, 파일
  -- 300개를 100개 디렉토리에 걸쳐 고치는 6초 동안 git 프로세스 336개. debounce_delay를 500으로
  -- 올려도 324개였다(디렉토리별로 따로 세기 때문). 큰 레포에서 느려지던 이유다.
  -- 갱신은 R(또는 <C-r>, <leader>tr), 그리고 nvim에서 저장할 때 된다.
  filesystem_watchers = {
    enable = false,
  },
  view = {
    -- 가장 긴 이름에 맞춰 넓어지되 화면의 35%까지만. 상한이 없으면 깊은 경로를 펼쳤을 때 트리가
    -- 편집 창을 밀어낸다(실측: 60칸 pane에서 트리 39 / 편집 20, 100칸에서 54 / 45).
    -- Herdr의 Nvim 토글이 nvim을 pane 절반에 띄우므로 좁은 화면이 흔하다.
    width = {
      min = 30,
      max = max_tree_width,
    },
    side = "left",
    signcolumn = "yes",
  },
  renderer = {
    group_empty = true,
    -- 문자열 enum이다("none"|"icon"|"name"|"all"). boolean을 넣으면
    -- legacy.lua:98-99가 조용히 "name"으로 변환하므로 처음부터 명시한다.
    highlight_git = "name",
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
    dotfiles = true,
    custom = { "node_modules", "^\\.git$", "^target$", "\\.DS_Store", "\\.cache" },
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
