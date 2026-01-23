-- Centralized diagnostic configuration for Neovim
-- This file consolidates all vim.diagnostic.config settings to avoid fragmentation

local M = {}

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

  -- Virtual lines disabled globally to prevent duplication with other display methods
  virtual_lines = false,

  -- Signs in the sign column
  signs = signs_opts,

  -- Underline settings
  underline = underline_opts,

  -- Update behavior
  update_in_insert = false, -- Performance optimization
  severity_sort = true,    -- Sort by severity

  -- Float window settings
  float = float_opts,

  -- Jump settings (Neovim 0.11+ feature)
  jump = {
    float = true,
    severity_limit = vim.diagnostic.severity.WARN,
  },
}

-- Performance optimized configuration (minimal display)
-- Only shows ERROR signs and lualine diagnostics
local performance_config = vim.tbl_deep_extend("force", default_config, {
  virtual_text = false,
  virtual_lines = false,
  update_in_insert = false,
  signs = {
    priority = 10,
    text = diagnostic_icons,
    severity = { min = vim.diagnostic.severity.ERROR },
  },
})

-- Development configuration with verbose output
-- Shows all diagnostic types with virtual text (virtual lines disabled to prevent duplication)
local development_config = vim.tbl_deep_extend("force", default_config, {
  virtual_text = virtual_text_opts,
  virtual_lines = false, -- Disabled to prevent duplication
  signs = signs_opts,
})

-- Apply diagnostic configuration
function M.setup(config_type)
  config_type = config_type or "default"

  local config
  if config_type == "performance" then
    config = performance_config
  elseif config_type == "development" then
    config = development_config
  else
    config = default_config
  end

  -- Apply the configuration
  vim.diagnostic.config(config)

  -- Set up diagnostic keymaps
  M.setup_keymaps()

  -- Set up autocommands
  M.setup_autocommands()
end

-- Setup diagnostic-related keymaps
function M.setup_keymaps()
  local opts = { noremap = true, silent = true }

  -- Diagnostic navigation
  vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))

  vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

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
    local current_config = vim.diagnostic.config()
  local virtual_text_enabled = current_config.virtual_text ~= false
  vim.diagnostic.config({
    virtual_text = virtual_text_enabled and false or virtual_text_opts,
  })
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

-- Setup diagnostic-related autocommands
function M.setup_autocommands()
  local augroup = vim.api.nvim_create_augroup("DiagnosticConfig", { clear = true })

  -- Auto-open float on cursor hold (disabled by default to avoid duplication)
  -- Uncomment below if you want automatic float display
  -- vim.api.nvim_create_autocmd("CursorHold", {
  -- 	group = augroup,
  -- 	pattern = "*",
  -- 	callback = function()
  -- 		-- Only show if there are diagnostics on the current line
  -- 		local line_diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  -- 		if #line_diagnostics > 0 then
  -- 			vim.diagnostic.open_float(nil, { focus = false })
  -- 		end
  -- 	end,
  -- 	desc = "Show diagnostics on cursor hold",
  -- })

  -- 대용량 파일 진단 비활성화는 cache_manager.lua에서 통합 관리됨
end

-- Get current diagnostic configuration
function M.get_config()
  return vim.diagnostic.config()
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

-- Utility function to get diagnostic status for statusline
function M.get_status()
  local diagnostics = vim.diagnostic.get(0)
  if #diagnostics == 0 then
    return "✓"
  end

  local counts = { errors = 0, warnings = 0, info = 0, hints = 0 }
  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      counts.errors = counts.errors + 1
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      counts.warnings = counts.warnings + 1
    elseif diagnostic.severity == vim.diagnostic.severity.INFO then
      counts.info = counts.info + 1
    elseif diagnostic.severity == vim.diagnostic.severity.HINT then
      counts.hints = counts.hints + 1
    end
  end

  local status = {}
  if counts.errors > 0 then
    table.insert(status, string.format("E:%d", counts.errors))
  end
  if counts.warnings > 0 then
    table.insert(status, string.format("W:%d", counts.warnings))
  end
  if counts.info > 0 then
    table.insert(status, string.format("I:%d", counts.info))
  end
  if counts.hints > 0 then
    table.insert(status, string.format("H:%d", counts.hints))
  end

  return table.concat(status, " ")
end

-- Export for global access
_G.diagnostic_status = M.get_status

return M
