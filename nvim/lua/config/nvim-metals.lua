local keys = require('config.nvim-lspconfig-keys')

vim.opt_global.shortmess:remove('F')

local metals_config = require('metals').bare_config()

-- Example of settings
metals_config.settings = {
  serverVersion = "0.11.10",
  showImplicitArguments = true,
  ammoniteJvmProperties = {"-Xmx2G"},
  bloopSbtAlreadyInstalled = true,
  excludedPackages = { 'akka.actor.typed.javadsl', 'com.github.swagger.akka.javadsl' },
}

metals_config.on_attach = keys.on_attach
metals_config.capabilities = require('cmp_nvim_lsp').default_capabilities()
metals_config.init_options.statusBarProvider = 'on'
metals_config.root_patterns = { '.git' }

-- Autocmd that will actually be in charging of starting the whole thing
local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  -- NOTE: You may or may not want java included here. You will need it if you
  -- want basic Java support but it may also conflict if you are using
  -- something like nvim-jdtls which also works on a java filetype autocmd.
  pattern = { 'scala', 'sbt', 'java' },
  callback = function(opts)
    require('metals').initialize_or_attach(metals_config)

    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = opts.buf,
      callback = function()
        vim.lsp.buf.format({ timeout_ms = 3000 })
      end,
    })
  end,
  group = nvim_metals_group,
})

