local M = {}

function M.default_capabilities(override)
	override = override or {}

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local completion = capabilities.textDocument.completion
	local completion_item = completion.completionItem

	completion.dynamicRegistration = override.dynamicRegistration or false
	completion.contextSupport = override.contextSupport
	if completion.contextSupport == nil then
		completion.contextSupport = true
	end
	completion.insertTextMode = override.insertTextMode or 1
	completion.completionList = override.completionList or {
		itemDefaults = {
			"commitCharacters",
			"editRange",
			"insertTextFormat",
			"insertTextMode",
			"data",
		},
	}

	completion_item.snippetSupport = override.snippetSupport
	if completion_item.snippetSupport == nil then
		completion_item.snippetSupport = true
	end
	completion_item.commitCharactersSupport = override.commitCharactersSupport
	if completion_item.commitCharactersSupport == nil then
		completion_item.commitCharactersSupport = true
	end
	completion_item.deprecatedSupport = override.deprecatedSupport
	if completion_item.deprecatedSupport == nil then
		completion_item.deprecatedSupport = true
	end
	completion_item.preselectSupport = override.preselectSupport
	if completion_item.preselectSupport == nil then
		completion_item.preselectSupport = true
	end
	completion_item.tagSupport = override.tagSupport or {
		valueSet = { 1 },
	}
	completion_item.insertReplaceSupport = override.insertReplaceSupport
	if completion_item.insertReplaceSupport == nil then
		completion_item.insertReplaceSupport = true
	end
	completion_item.resolveSupport = override.resolveSupport or {
		properties = {
			"documentation",
			"additionalTextEdits",
			"insertTextFormat",
			"insertTextMode",
			"command",
		},
	}
	completion_item.insertTextModeSupport = override.insertTextModeSupport or {
		valueSet = { 1, 2 },
	}
	completion_item.labelDetailsSupport = override.labelDetailsSupport
	if completion_item.labelDetailsSupport == nil then
		completion_item.labelDetailsSupport = true
	end

	return capabilities
end

return M
