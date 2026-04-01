local M = {}

function M.setup()
  require("nvim-treesitter-textobjects").setup({
    select = {
      lookahead = true,
    },
    move = {
      set_jumps = true,
    },
  })

  local select = require("nvim-treesitter-textobjects.select")
  local move = require("nvim-treesitter-textobjects.move")

  local select_keymaps = {
    af = "@function.outer",
    ["if"] = "@function.inner",
    ac = "@class.outer",
    ic = "@class.inner",
    aa = "@parameter.outer",
    ia = "@parameter.inner",
    ab = "@block.outer",
    ib = "@block.inner",
    al = "@loop.outer",
    il = "@loop.inner",
    ad = "@conditional.outer",
    id = "@conditional.inner",
  }

  for keymap, query in pairs(select_keymaps) do
    vim.keymap.set({ "x", "o" }, keymap, function()
      select.select_textobject(query, "textobjects")
    end, { desc = "Treesitter textobject: " .. query })
  end

  local move_keymaps = {
    ["]m"] = function()
      move.goto_next_start("@function.outer", "textobjects")
    end,
    ["]]"] = function()
      move.goto_next_start("@class.outer", "textobjects")
    end,
    ["]d"] = function()
      move.goto_next_start("@conditional.outer", "textobjects")
    end,
    ["]l"] = function()
      move.goto_next_start("@loop.outer", "textobjects")
    end,
    ["]M"] = function()
      move.goto_next_end("@function.outer", "textobjects")
    end,
    ["]["] = function()
      move.goto_next_end("@class.outer", "textobjects")
    end,
    ["[m"] = function()
      move.goto_previous_start("@function.outer", "textobjects")
    end,
    ["[["] = function()
      move.goto_previous_start("@class.outer", "textobjects")
    end,
    ["[d"] = function()
      move.goto_previous_start("@conditional.outer", "textobjects")
    end,
    ["[l"] = function()
      move.goto_previous_start("@loop.outer", "textobjects")
    end,
    ["[M"] = function()
      move.goto_previous_end("@function.outer", "textobjects")
    end,
    ["[]"] = function()
      move.goto_previous_end("@class.outer", "textobjects")
    end,
  }

  for keymap, handler in pairs(move_keymaps) do
    vim.keymap.set({ "n", "x", "o" }, keymap, handler, { desc = "Treesitter move: " .. keymap })
  end
end

return M
