vim.keymap.set(
  '',
  '<C-c>',
  function()
    if vim.bo.filetype ~= 'NvimTree' then
      require('bufdelete').bufdelete(0, true)
    end
  end,
  { silent = true }
)
