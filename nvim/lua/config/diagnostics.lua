-- Centralized diagnostic configuration for Neovim
-- This file consolidates all vim.diagnostic.config settings to avoid fragmentation

local M = {}

local valid_modes = {
  default = true,
  performance = true,
  development = true,
}

-- Diagnostic icons for different severity levels
local diagnostic_icons = {
  [vim.diagnostic.severity.ERROR] = "✘",
  [vim.diagnostic.severity.WARN] = "▲",
  [vim.diagnostic.severity.INFO] = "●",
  [vim.diagnostic.severity.HINT] = "◆",
}

local virtual_text_opts = {
  prefix = function(diagnostic)
    return diagnostic_icons[diagnostic.severity] or "●"
  end,
  spacing = 4,
  source = false, -- Hide source to keep messages clean
  format = function(diagnostic)
    -- Format diagnostic message without source to keep it clean
    return diagnostic.message
  end,
}

local float_opts = {
  focusable = false,
  style = "minimal",
  border = "rounded",
  source = false, -- Hide source to keep messages clean
  header = "",
  prefix = function(diagnostic)
    return (diagnostic_icons[diagnostic.severity] or "●") .. " "
  end,
  format = function(diagnostic)
    -- Format diagnostic message without source to keep it clean
    return diagnostic.message
  end,
}

local function show_jump_diagnostic(diagnostic, bufnr)
  if not diagnostic then
    return
  end

  vim.diagnostic.open_float({
    bufnr = bufnr,
    scope = "cursor",
    focus = false,
  })
end

local signs_opts = {
  priority = 10,
  text = diagnostic_icons,
  severity = { min = vim.diagnostic.severity.HINT },
}

local underline_opts = {
  severity = { min = vim.diagnostic.severity.WARN },
}

-- Default diagnostic configuration
local default_config = {
  -- Virtual text disabled by default
  virtual_text = false,

  -- vim.diagnostic.config()는 전달된 키만 대입하고 나머지는 현재 값을 유지하므로,
  -- 모드 전환이 항상 virtual lines를 끄도록 명시적으로 false를 유지한다.
  virtual_lines = false,

  -- Signs in the sign column
  signs = signs_opts,

  -- Underline settings
  underline = underline_opts,

  -- Update behavior
  update_in_insert = false, -- Performance optimization
  severity_sort = true, -- Sort by severity

  -- Float window settings
  float = float_opts,

  -- Jump settings (Neovim 0.11+ feature)
  jump = {
    on_jump = show_jump_diagnostic,
    severity = { min = vim.diagnostic.severity.WARN },
  },
}

-- Performance optimized configuration (minimal display)
-- Only shows ERROR signs and lualine diagnostics
local performance_config = vim.tbl_deep_extend("force", default_config, {
  virtual_text = false,
  update_in_insert = false,
  signs = {
    priority = 10,
    text = diagnostic_icons,
    severity = { min = vim.diagnostic.severity.ERROR },
  },
})

-- Development configuration with verbose output
-- Shows all diagnostic types with virtual text
local development_config = vim.tbl_deep_extend("force", default_config, {
  virtual_text = virtual_text_opts,
  signs = signs_opts,
})

-- Apply diagnostic configuration
function M.setup(config_type)
  local mode = config_type or vim.g.diagnostic_mode or "default"
  if not valid_modes[mode] then
    mode = "default"
  end
  vim.g.diagnostic_mode = mode

  local config
  if mode == "performance" then
    config = performance_config
  elseif mode == "development" then
    config = development_config
  else
    config = default_config
  end

  -- Apply the configuration
  vim.diagnostic.config(config)

  -- Set up diagnostic keymaps
  M.setup_keymaps()
end

-- Setup diagnostic-related keymaps
function M.setup_keymaps()
  local opts = { noremap = true, silent = true }

  -- 진단 이동은 0.11 기본 매핑 [d / ]d를 사용한다 (중복 매핑 제거)

  -- Diagnostic display
  vim.keymap.set(
    "n",
    "<leader>e",
    vim.diagnostic.open_float,
    vim.tbl_extend("force", opts, { desc = "Show line diagnostics" })
  )

  vim.keymap.set(
    "n",
    "<leader>q",
    vim.diagnostic.setqflist,
    vim.tbl_extend("force", opts, { desc = "Add diagnostics to quickfix" })
  )

  -- Toggle virtual text
  vim.keymap.set("n", "<leader>dt", function()
    -- vim.diagnostic.config()는 인자 없이 부르면 항상 현재 설정 table을 돌려주지만
    -- 주석상 반환 타입이 table?이라 가드를 둔다.
    local current_config = vim.diagnostic.config() or {}
    local virtual_text_enabled = current_config.virtual_text ~= false
    -- `cond and false or x`는 항상 x가 되므로 끄는 쪽이 동작하지 않는다. 분기로 고른다.
    ---@type vim.diagnostic.Opts.VirtualText|false
    local new_virtual_text = virtual_text_opts
    if virtual_text_enabled then
      new_virtual_text = false
    end
    vim.diagnostic.config({ virtual_text = new_virtual_text })
    vim.notify(string.format("Virtual text %s", virtual_text_enabled and "disabled" or "enabled"))
  end, vim.tbl_extend("force", opts, { desc = "Toggle diagnostic virtual text" }))

  -- Virtual lines toggle disabled (feature removed to prevent duplication)
  -- vim.keymap.set("n", "<leader>dl", function()
  -- 	local current_config = vim.diagnostic.config()
  -- 	local virtual_lines_enabled = current_config.virtual_lines and current_config.virtual_lines.enabled
  -- 	vim.diagnostic.config({
  -- 		virtual_lines = { enabled = not virtual_lines_enabled }
  -- 	})
  -- 	vim.notify(string.format("Virtual lines %s", virtual_lines_enabled and "disabled" or "enabled"))
  -- end, vim.tbl_extend("force", opts, { desc = "Toggle diagnostic virtual lines" }))
end

-- Toggle between different configuration modes
function M.toggle_mode()
  local current = vim.g.diagnostic_mode or "default"
  local modes = { "default", "performance", "development" }
  local next_index = 1

  for i, mode in ipairs(modes) do
    if mode == current then
      next_index = (i % #modes) + 1
      break
    end
  end

  local next_mode = modes[next_index]
  vim.g.diagnostic_mode = next_mode
  M.setup(next_mode)
  vim.notify(string.format("Diagnostic mode: %s", next_mode))
end

return M
