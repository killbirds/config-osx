require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = "catppuccin",
    component_separators = {left = '', right = ''},
    section_separators = {left = '', right = ''},
    disabled_filetypes = {'packer', 'NvimTree'},
    always_divide_middle = true,
    globalstatus = false,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff'},
    lualine_c = {{'filename', path = 1, shorting_target = 40},},
    lualine_x = {'filetype'},
    lualine_y = {'encoding', 'fileformat'},
    lualine_z = {
      {'progress', icons_enabled = false },
      {'location', icons_enabled = false },
    },
  },
  tabline = {},
  extensions = { 'fugitive', 'nvim-tree' },
}
